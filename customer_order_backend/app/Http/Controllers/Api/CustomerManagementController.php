<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class CustomerManagementController extends Controller
{
    /**
     * Delete a customer.
     */
    public function destroy($id)
    {
        try {
            $customer = Customer::findOrFail($id);
            
            // Log the deletion for audit
            Log::info('Customer deleted by admin', ['customer_id' => $id, 'email' => $customer->email]);

            $customer->delete();

            return response()->json([
                'message' => 'Customer deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            Log::error('Failed to delete customer', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Failed to delete customer'
            ], 500);
        }
    }
}
