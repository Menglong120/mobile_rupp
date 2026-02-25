<?php

namespace App\Services;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

class TelegramService
{
    protected $client;
    protected $token;
    protected $chatId;

    public function __construct()
    {
        $this->token = '8598295374:AAF9PIMmKornwqstfXsUh_JIhgpB_gtlbc8';
        $this->chatId = '1092601140';
        $this->client = new Client();
    }

    public function sendMessage($message)
    {
        $payload = [
            'chat_id' => (int)$this->chatId,
            'text' => strip_tags($message),
        ];

        Log::info('Sending Telegram notification', ['payload' => $payload]);

        try {
            $url = "https://api.telegram.org/bot{$this->token}/sendMessage";
            $response = $this->client->post($url, [
                'json' => $payload,
            ]);

            $result = json_decode($response->getBody()->getContents(), true);
            Log::info('Telegram notification response', ['result' => $result]);
            return $result;
        } catch (\Exception $e) {
            Log::error('Telegram notification failed: ' . $e->getMessage());
            if (method_exists($e, 'getResponse') && $e->getResponse()) {
                Log::error('Telegram error response: ' . $e->getResponse()->getBody()->getContents());
            }
            return false;
        }
    }
}
