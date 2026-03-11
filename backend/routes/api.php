<?php

use App\Http\Controllers\Api\ProductApiController;
use App\Http\Controllers\Api\CustomerApiController;
use App\Http\Controllers\Api\OrderApiController;
use App\Http\Controllers\Api\OrderItemApiController;
use App\Http\Controllers\Api\CustomerAddressController;
use App\Http\Controllers\Api\CustomerIndexController;
use App\Http\Controllers\Api\CustomerManagementController;
use App\Http\Controllers\Api\CategoryApiController;
use Illuminate\Http\Request;

Route::apiResource('/categories', CategoryApiController::class);
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::get('/system-status', function () {
    try {
        $dbConnection = DB::connection()->getPdo();
        $dbName = DB::connection()->getDatabaseName();
        $dbDriver = DB::connection()->getDriverName();
        return response()->json([
            'status' => 'connected',
            'database' => [
                'name' => $dbName,
                'driver' => $dbDriver,
                'schema' => config('database.connections.pgsql.search_path', 'public')
            ]
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'disconnected',
            'error' => $e->getMessage()
        ], 500);
    }
});

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::apiResource('/products', ProductApiController::class);
Route::get('/products/{pid}/image', [ProductApiController::class, 'getImage']);


Route::post('/customer/auth', [CustomerApiController::class, 'auth']);
Route::post('/customer/verify', [CustomerApiController::class, 'verify']);
Route::post('/customer/setup', [CustomerApiController::class, 'setup']);
Route::get('/customer/show', [CustomerApiController::class, 'show']);
Route::post('/customer/photo', [CustomerApiController::class, 'updatePhoto']);
Route::post('/customer/login', [CustomerApiController::class, 'login']);
Route::get('/customers', CustomerIndexController::class);
Route::delete('/customers/{id}', [CustomerManagementController::class, 'destroy']);

Route::post('/customer/request-reset-password', [CustomerApiController::class, 'requestResetPassword']);
Route::post('/customer/resend-otp', [CustomerApiController::class, 'resendOtp']);
Route::post('/customer/verify-reset-otp', [CustomerApiController::class, 'verifyResetOtp']);
Route::post('/customer/reset-password', [CustomerApiController::class, 'resetPassword']);
Route::post('/test-email', [CustomerApiController::class, 'testEmail']);


Route::post('/orders/place', [OrderApiController::class, 'placeOrder']);
Route::get('/orders', [OrderApiController::class, 'index']);
Route::get('/orders/customer/{customer_id}', [OrderApiController::class, 'listByCustomer']);
Route::get('/orders/{oid}', [OrderApiController::class, 'show']);
Route::put('/orders/{oid}/status', [OrderApiController::class, 'updateStatus']);

// Bakong Payment Routes
Route::post('/payments/generate-khqr', [OrderApiController::class, 'generateKhqr']);
Route::post('/payments/check-status', [OrderApiController::class, 'checkPaymentStatus']);
Route::post('/payments/bakong-callback', [OrderApiController::class, 'handleBakongCallback']);
Route::post('/payments/mark-completed', [OrderApiController::class, 'markPaymentCompleted']);

// Customer Address Routes
Route::apiResource('/customer-addresses', CustomerAddressController::class);
Route::get('/customer-addresses/customer/{customer_id}', [CustomerAddressController::class, 'listByCustomer']);


Route::get('orders/{order_id}/items', [OrderItemApiController::class, 'index']);
Route::post('orders/{order_id}/items', [OrderItemApiController::class, 'store']);
Route::put('orders/{order_id}/items/{item_id}', [OrderItemApiController::class, 'update']);
Route::delete('orders/{order_id}/items/{item_id}', [OrderItemApiController::class, 'destroy']);
