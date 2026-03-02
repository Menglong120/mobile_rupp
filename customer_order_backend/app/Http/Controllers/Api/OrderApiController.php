<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\PaymentRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use App\Services\BakongService;
use App\Services\TelegramService;

class OrderApiController extends Controller
{
    public function placeOrder(Request $request, TelegramService $telegramService)
    {
        $validator = Validator::make($request->all(), [
            'customer_id'          => 'required|exists:customers,cid',
            'address_id'           => 'required|exists:customer_addresses,id',
            'items'                => 'required|array|min:1',
            'items.*.product_id'   => 'required|exists:products,pid',
            'items.*.quantity'     => 'required|integer|min:1',
            'items.*.size'         => 'nullable|string',
            'payment_method'       => 'nullable|string|in:cash,bakong',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $paymentMethod = $request->input('payment_method', 'cash');
        $total         = 0;
        $orderItems    = [];

        // Pre-validate stock and calculate total
        foreach ($request->items as $item) {
            $product = Product::find($item['product_id']);
            if (!$product) {
                return response()->json(['message' => 'Product ' . $item['product_id'] . ' not found'], 404);
            }
            if ($product->stock < $item['quantity']) {
                return response()->json(['message' => 'Not enough stock for product: ' . $product->name], 400);
            }
            $subtotal     = $product->price * $item['quantity'];
            $total       += $subtotal;
            $orderItems[] = [
                'product_id' => $product->pid,
                'quantity'   => $item['quantity'],
                'size'       => $item['size'] ?? null,
                'price'      => $product->price,
            ];
        }

        // ── Bakong: create a PaymentRequest first, finalize after payment confirmed ──
        if ($paymentMethod === 'bakong') {
            $paymentRequest = PaymentRequest::create([
                'customer_id'  => $request->customer_id,
                'address_id'   => $request->address_id,
                'items'        => $orderItems,
                'total_amount' => $total,
                'status'       => 'pending',
            ]);

            return response()->json([
                'message'            => 'Payment request created',
                'order_id'           => $paymentRequest->id,
                'is_pending_payment' => true,
            ]);
        }

        // ── Cash: create order immediately ──
        $order = Order::create([
            'customer_id'  => $request->customer_id,
            'address_id'   => $request->address_id,
            'total_amount' => $total,
            'status'       => 'pending',
        ]);

        foreach ($orderItems as $item) {
            $product        = Product::find($item['product_id']);
            $product->stock -= $item['quantity'];
            $product->save();

            OrderItem::create([
                'order_id'   => $order->oid,
                'product_id' => $item['product_id'],
                'quantity'   => $item['quantity'],
                'size'       => $item['size'],
                'price'      => $item['price'],
            ]);
        }

        // Send Telegram notification for cash orders
        $order        = Order::with('customer')->find($order->oid);
        $customerName = $order->customer->full_name ?? 'Unknown Customer';
        $amount       = number_format($order->total_amount, 2);
        $time         = now()->toDateTimeString();

        $telegramService->sendMessage(
            "🛒 New Order (Cash)!\n\n" .
            "Order: #{$order->oid}\n" .
            "Customer: {$customerName}\n" .
            "Amount: \${$amount}\n" .
            "Time: {$time}"
        );

        return response()->json([
            'message'            => 'Order placed',
            'order_id'           => $order->oid,
            'is_pending_payment' => false,
        ]);
    }

    public function index()
    {
        $orders = Order::with(['customer', 'items.product', 'address'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($orders, 200);
    }

    public function listByCustomer($customer_id)
    {
        $orders = Order::where('customer_id', $customer_id)
            ->with(['items.product', 'address'])
            ->get();

        return response()->json($orders, 200);
    }

    public function show($oid)
    {
        $order = Order::with(['items.product', 'address'])->find($oid);

        if (!$order) {
            return response()->json(['message' => 'Order not found'], 404);
        }

        return response()->json($order, 200);
    }

    public function updateStatus(Request $request, $oid)
    {
        $order = Order::find($oid);
        if (!$order) {
            return response()->json(['message' => 'Order not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:pending,processing,shipped,completed,cancelled',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $order->status = $request->status;
        $order->save();

        return response()->json([
            'message' => 'Order status updated successfully',
            'data' => $order
        ], 200);
    }

    public function generateKhqr(Request $request, BakongService $bakongService)
    {
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|string',
            'currency' => 'nullable|string|in:USD,KHR',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $id             = $request->order_id;
        $paymentRequest = PaymentRequest::find($id);

        if ($paymentRequest) {
            $order = (object) [
                'oid'          => $paymentRequest->id,
                'total_amount' => $paymentRequest->total_amount,
            ];
        } else {
            $order = Order::find($id);
        }

        if (!$order) {
            return response()->json(['message' => 'Order or Payment Request not found'], 404);
        }

        $currency = $request->input('currency', 'USD');
        $khqr     = $bakongService->generateKhqr($order, $currency);
        $qrImage  = $bakongService->generateQrImage($khqr);

        return response()->json([
            'success'  => true,
            'orderId'  => $id,
            'qrString' => $khqr,
            'qrImage'  => $qrImage,
        ]);
    }

    public function checkPaymentStatus(Request $request, BakongService $bakongService, TelegramService $telegramService)
    {
        $validator = Validator::make($request->all(), [
            'order_id' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $id     = $request->order_id;
        $isMock = filter_var($request->input('mock', false), FILTER_VALIDATE_BOOLEAN) 
          || env('BAKONG_MOCK', false);

        error_log("BAKONG_DEBUG: checkPaymentStatus for ID: {$id}" . ($isMock ? ' (MOCK)' : ''));

        // ── Fast path #1: PaymentRequest marked paid
        $paymentRequest = PaymentRequest::find($id);
        if ($paymentRequest && $paymentRequest->status === 'paid') {
            $this->finalizePaymentRequest($paymentRequest, $telegramService);
            return response()->json([
                'success' => true,
                'status'  => 'SUCCESS',
                'message' => 'Payment confirmed locally',
            ]);
        }

        // ── Fast path #2: Real Order already finalized and paid
        $existingOrder = Order::where('payment_id', $id)
            ->orWhere('oid', $id)
            ->first();

        if ($existingOrder && $existingOrder->status === 'paid') {
            error_log("BAKONG_DEBUG: Order {$id} already paid — Returning SUCCESS");
            return response()->json([
                'success' => true,
                'status'  => 'SUCCESS',
                'message' => 'Payment already verified locally',
            ]);
        }

        // ── Mock or Real logic
        if ($isMock) {
            $cacheKey  = 'bakong_mock_poll_' . $id;
            $pollCount = Cache::get($cacheKey, 0) + 1;
            Cache::put($cacheKey, $pollCount, now()->addMinutes(20));

            if ($pollCount >= 3) {
                Cache::forget($cacheKey);
                $status = ['status' => 'SUCCESS', 'message' => 'Mock payment confirmed'];
            } else {
                $status = ['status' => 'PENDING', 'message' => "Mock: poll #{$pollCount}"];
            }
        } else {
            $status = $bakongService->checkTransactionStatus($id);
        }

        // Finalize if success
        if ($status['status'] === 'SUCCESS') {
            if ($paymentRequest) {
                $paymentRequest->status = 'paid';
                $paymentRequest->save();
                $this->finalizePaymentRequest($paymentRequest, $telegramService);
            } elseif ($existingOrder && $existingOrder->status !== 'paid') {
                $existingOrder->status = 'paid';
                $existingOrder->save();
            }
        }

        return response()->json([
            'success' => true,
            'status'  => $status['status'],
            'message' => $status['message'] ?? '',
        ]);
    }


    public function handleBakongCallback(Request $request, BakongService $bakongService, TelegramService $telegramService)
    {
        Log::info('Bakong Callback Received', ['data' => $request->all()]);

        if (!$bakongService->verifyCallback($request->all())) {
            Log::warning('Bakong Callback: Invalid Signature', ['data' => $request->all()]);
            return response()->json(['status' => 'invalid signature'], 400);
        }

        $id = $request->orderId;

        // The ID from Bakong callback is the 25-char billNumber (truncated UUID)
        $paymentRequest = PaymentRequest::where('id', 'like', $id . '%')->first();

        if ($paymentRequest) {
            // Mark paid so the polling fast-path catches it immediately
            if ($paymentRequest->status !== 'paid') {
                $paymentRequest->status = 'paid';
                $paymentRequest->save();
                $this->finalizePaymentRequest($paymentRequest, $telegramService);
            }
        } else {
            $finalOrder = Order::with('customer')
                ->where('payment_id', 'like', $id . '%')
                ->orWhere('oid', $id)
                ->first();

            if ($finalOrder && $finalOrder->status !== 'paid') {
                $finalOrder->status = 'paid';
                $finalOrder->save();

                $customerName = $finalOrder->customer->full_name ?? 'Unknown Customer';
                $amount       = number_format($finalOrder->total_amount, 2);

                $telegramService->sendMessage(
                    "✅ Order Paid (Bakong Callback)!\n\n" .
                    "Order: #{$finalOrder->oid}\n" .
                    "Customer: {$customerName}\n" .
                    "Amount: \${$amount}\n" .
                    "Time: " . now()->toDateTimeString()
                );
            }
        }

        return response()->json(['status' => 'success']);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // Private Helpers
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Convert a pending PaymentRequest into a real paid Order.
     * Safe to call multiple times — idempotent via payment_id check.
     */
    private function finalizePaymentRequest(PaymentRequest $paymentRequest, TelegramService $telegramService): ?Order
    {
        // Idempotency guard: don't create a duplicate order
        $existingOrder = Order::where('payment_id', $paymentRequest->id)->first();
        if ($existingOrder) {
            error_log("BAKONG_DEBUG: Order already exists for PaymentRequest {$paymentRequest->id} — deleting request and returning");
            $paymentRequest->delete();
            return $existingOrder;
        }


        $finalOrder = Order::create([
            'customer_id'  => $paymentRequest->customer_id,
            'address_id'   => $paymentRequest->address_id,
            'total_amount' => $paymentRequest->total_amount,
            'status'       => 'paid',
            'payment_id'   => $paymentRequest->id,
        ]);

        foreach ($paymentRequest->items as $item) {
            $product = Product::find($item['product_id']);
            if ($product) {
                $product->stock -= $item['quantity'];
                $product->save();
            }

            OrderItem::create([
                'order_id'   => $finalOrder->oid,
                'product_id' => $item['product_id'],
                'quantity'   => $item['quantity'],
                'price'      => $item['price'],
            ]);
        }

        // Delete the PaymentRequest — it's been promoted to a real Order
        $paymentRequest->delete();

        // Reload with relations for notification
        $finalOrder   = Order::with('customer')->find($finalOrder->oid);
        $customerName = $finalOrder->customer->full_name ?? 'Unknown Customer';
        $amount       = number_format($finalOrder->total_amount, 2);

        $telegramService->sendMessage(
            "✅ New Order Paid (Bakong)!\n\n" .
            "Order: #{$finalOrder->oid}\n" .
            "Customer: {$customerName}\n" .
            "Amount: \${$amount}\n" .
            "Time: " . now()->toDateTimeString()
        );

        return $finalOrder;
    }
}