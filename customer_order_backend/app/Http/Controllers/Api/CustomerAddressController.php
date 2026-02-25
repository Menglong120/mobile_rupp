<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CustomerAddressController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return response()->json(\App\Models\CustomerAddress::all());
    }

    public function listByCustomer($customer_id)
    {
        $addresses = \App\Models\CustomerAddress::where('customer_id', $customer_id)->get();
        return response()->json($addresses);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'customer_id' => 'required|exists:customers,cid',
            'address_line' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'label' => 'nullable|string',
            'is_default' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->is_default) {
            \App\Models\CustomerAddress::where('customer_id', $request->customer_id)
                ->update(['is_default' => false]);
        }

        $address = \App\Models\CustomerAddress::create($request->all());

        return response()->json($address, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $address = \App\Models\CustomerAddress::findOrFail($id);
        return response()->json($address);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $address = \App\Models\CustomerAddress::findOrFail($id);

        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'address_line' => 'sometimes|required|string',
            'latitude' => 'sometimes|required|numeric',
            'longitude' => 'sometimes|required|numeric',
            'label' => 'nullable|string',
            'is_default' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->is_default) {
            \App\Models\CustomerAddress::where('customer_id', $address->customer_id)
                ->update(['is_default' => false]);
        }

        $address->update($request->all());

        return response()->json($address);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $address = \App\Models\CustomerAddress::findOrFail($id);
        $address->delete();

        return response()->json(['message' => 'Address deleted successfully']);
    }
}
