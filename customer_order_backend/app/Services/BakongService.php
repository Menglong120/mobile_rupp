<?php

namespace App\Services;

use GuzzleHttp\Client;
use chillerlan\QRCode\QRCode;
use chillerlan\QRCode\QROptions;
use Illuminate\Support\Facades\Log;

class BakongService
{
    protected $client;
    protected $baseUrl;
    protected $merchantId;
    protected $merchantIdCode;
    protected $merchantName;
    protected $merchantCity;
    protected $acquiringBank;
    protected $secretKey;

    public function __construct()
    {
        $this->baseUrl       = env('BAKONG_BASE_URL', 'https://bakong-dev.nbc.gov.kh/api/v1');
        $this->merchantId    = env('MERCHANT_ID', 'menglong_bo@bkrt');
        $this->merchantIdCode = env('MERCHANT_ID_CODE', '000001');
        $this->merchantName  = env('MERCHANT_NAME', 'Menglong Bo');
        $this->merchantCity  = env('MERCHANT_CITY', 'Phnom Penh');
        $this->acquiringBank = env('ACQUIRING_BANK', 'Bakong');
        $this->secretKey     = env('SECRET_KEY');

        $baseUri = rtrim($this->baseUrl, '/') . '/';

        $this->client = new Client([
            'base_uri'        => $baseUri,
            'timeout'         => 8.0,
            'connect_timeout' => 3.0,
            'verify'          => false,
            'headers'         => [
                'Authorization' => 'Bearer ' . $this->secretKey,
                'Content-Type'  => 'application/json',
                'Accept'        => 'application/json',
            ],
        ]);
    }

    public function generateMD5($data)
    {
        return md5($data);
    }

    public function verifyCallback($data)
    {
        $rawString           = ($data['amount'] ?? '') . ($data['orderId'] ?? '') . ($data['merchantId'] ?? '') . $this->secretKey;
        $calculatedSignature = md5($rawString);
        return $calculatedSignature === ($data['signature'] ?? '');
    }

    public function generateKhqr($order, $currency = 'USD')
    {
        $rawAmount = (float) $order->total_amount;

        if (strtoupper($currency) === 'KHR') {
            $rawAmount    = $rawAmount * 4100;
            $amount       = (string) (int) round($rawAmount);
            $currencyCode = '116'; // KHR
        } else {
            $amount       = number_format($rawAmount, 2, '.', '');
            $currencyCode = '840'; // USD
        }

        $tag30_00 = $this->formatTag('00', $this->merchantId);
        $tag30_01 = $this->formatTag('01', $this->merchantIdCode);
        $tag30_02 = $this->formatTag('02', $this->acquiringBank);
        $tag30    = $this->formatTag('30', $tag30_00 . $tag30_01 . $tag30_02);

        $payload  = '';
        $payload .= $this->formatTag('00', '01');   // Payload Format Indicator
        $payload .= $this->formatTag('01', '12');   // Point of Initiation (dynamic)
        $payload .= $tag30;
        $payload .= $this->formatTag('52', '5999'); // MCC
        $payload .= $this->formatTag('53', $currencyCode);
        $payload .= $this->formatTag('54', $amount);
        $payload .= $this->formatTag('58', 'KH');
        $payload .= $this->formatTag('59', $this->merchantName);
        $payload .= $this->formatTag('60', $this->merchantCity);

        // Tag 62: Bill Number — must be max 25 chars, store exactly what you hash later
        $orderId    = (string) $order->oid;
        $billNumber = substr($orderId, 0, 25);
        $tag62_01   = $this->formatTag('01', $billNumber);
        $payload   .= $this->formatTag('62', $tag62_01);

        // Tag 99: Expiration (15 min from now in ms)
        $expirationTimestamp = (int) ((time() + 15 * 60) * 1000);
        $payload            .= $this->formatTag('99', (string) $expirationTimestamp);

        // CRC
        $payload .= '6304';
        $crc      = $this->crc16($payload);

        return $payload . $crc;
    }

    public function generateQrImage($qrString)
    {
        $options = new QROptions([
            'outputType'  => QRCode::OUTPUT_MARKUP_SVG,
            'eccLevel'    => QRCode::ECC_L,
            'scale'       => 8,
            'outputBase64' => true,
            'quietzoneSize' => 2,
        ]);

        $qr = new QRCode($options);
        return $qr->render($qrString);
    }

    /**
     * Check if a Bakong transaction has been paid.
     *
     * Bakong responseCode meanings:
     *   0  → Transaction FOUND and PAID (success)
     *   1  → Transaction not found / still pending
     *   Other → Error
     *
     * @param  string $transactionId  The original order ID (oid)
     * @return array  ['status' => 'SUCCESS|PENDING|ERROR', 'message' => '...']
     */
    public function checkTransactionStatus($transactionId)
    {
        try {
            // Must match exactly what was put in Tag 62 during QR generation
            $billNumber = substr((string) $transactionId, 0, 25);

            // Bakong MD5 hash = md5(merchantId + billNumber)
            $hash = md5($this->merchantId . $billNumber);

            $payload = [
                'merchantAccount' => $this->merchantId,
                'hash'            => $hash,
            ];

            Log::info('Bakong: checking transaction status', [
                'transactionId' => $transactionId,
                'billNumber'    => $billNumber,
                'hash'          => $hash,
                'endpoint'      => 'check_transaction_by_md5',
            ]);

            $response = $this->client->post('check_transaction_by_md5', [
                'json' => $payload,
            ]);

            $result = json_decode($response->getBody()->getContents(), true);

            Log::info('Bakong: API response', ['result' => $result]);

            $responseCode = $result['responseCode'] ?? -1;
            $responseMsg  = $result['responseMessage'] ?? 'No message';

            // ✅ responseCode 0 = payment confirmed by Bakong
            if ($responseCode === 0) {
                Log::info('Bakong: payment SUCCESS', ['transactionId' => $transactionId]);
                return [
                    'status'  => 'SUCCESS',
                    'message' => $responseMsg,
                    'data'    => $result['data'] ?? [],
                ];
            }

            // responseCode 1 = not yet paid / pending
            if ($responseCode === 1) {
                return [
                    'status'  => 'PENDING',
                    'message' => $responseMsg,
                ];
            }

            // Any other code = treat as error/unknown
            Log::warning('Bakong: unexpected responseCode', ['responseCode' => $responseCode, 'message' => $responseMsg]);
            return [
                'status'  => 'PENDING',
                'message' => $responseMsg,
            ];

        } catch (\GuzzleHttp\Exception\ConnectException $e) {
            Log::error('Bakong: connection failed', ['error' => $e->getMessage()]);
            return ['status' => 'ERROR', 'message' => 'Connection failed: ' . $e->getMessage()];
        } catch (\Exception $e) {
            Log::error('Bakong: unexpected error', ['error' => $e->getMessage()]);
            return ['status' => 'ERROR', 'message' => $e->getMessage()];
        }
    }

    /* ========================= Private Helpers ========================= */

    private function formatTag($tag, $value)
    {
        return $tag . str_pad(strlen($value), 2, '0', STR_PAD_LEFT) . $value;
    }

    private function crc16($data)
    {
        $crc = 0xFFFF;
        for ($i = 0; $i < strlen($data); $i++) {
            $x    = (($crc >> 8) ^ ord($data[$i])) & 0xFF;
            $x   ^= $x >> 4;
            $crc  = (($crc << 8) ^ ($x << 12) ^ ($x << 5) ^ $x) & 0xFFFF;
        }
        return strtoupper(str_pad(dechex($crc), 4, '0', STR_PAD_LEFT));
    }
}