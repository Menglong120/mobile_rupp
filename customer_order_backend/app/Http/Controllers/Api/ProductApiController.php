<?php

namespace App\Http\Controllers\Api;

use App\Models\Product;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Api\Error;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Exception;


class ProductApiController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with('category');

        if ($request->has('category_id') && $request->category_id !== 'all') {
            $query->where('category_id', $request->category_id);
        }

        $products = $query->get()->map(function ($product) {
            return $this->formatProductResponse($product);
        });

        return response()->json($products, 200);
    }

    public function store(Request $request)
    {
        // Debug: Log all incoming request data
        \Illuminate\Support\Facades\Log::info('Product store attempt:', $request->all());

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            // Completely removing specific mimes for image to bypass browser/GD compatibility issues
            'image' => 'nullable|file|max:20480', 
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $product = new Product();
            $product->name = $request->name;
            $product->description = $request->description ?? '';
            $product->price = (float)$request->price;
            $product->stock = (int)$request->stock;
            $product->category_id = (int)$request->category_id;
            
            // Sync with legacy cid if it exists in DB
            $product->cid = (int)$request->category_id;
            
            if ($request->hasFile('image')) {
                $product->image = $this->storeImage($request->file('image'));
            }

            $product->save();

            return response()->json([
                'message' => 'Product created successfully',
                'data' => $this->formatProductResponse($product->load('category'))
            ], 201);

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Product save error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Database error',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, string $pid)
    {
        $product = Product::find($pid);
        if (!$product) return response()->json(['message' => 'Product not found'], 404);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'price' => 'sometimes|numeric|min:0',
            'stock' => 'sometimes|integer|min:0',
            'category_id' => 'sometimes|exists:categories,id',
            'image' => 'nullable|file|max:20480',
        ]);
        if ($validator->fails()) return response()->json(['errors' => $validator->errors()], 422);

        if ($request->has('name')) $product->name = $request->name;
        if ($request->has('description')) $product->description = $request->description;
        if ($request->has('price')) $product->price = (float)$request->price;
        if ($request->has('stock')) $product->stock = (int)$request->stock;
        if ($request->has('category_id')) {
            $product->category_id = (int)$request->category_id;
            $product->cid = (int)$request->category_id;
        }

        if ($request->hasFile('image')) {
            if ($product->image) {
                $imagePath = $this->normalizeStoredImagePath($product->image);
                Storage::disk('public')->delete($imagePath);
            }
            $product->image = $this->storeImage($request->file('image'));
        }
        $product->save();

        return response()->json([
            'message' => 'Product updated successfully',
            'data' => $this->formatProductResponse($product->load('category'))
        ], 200);
    }

    protected function formatProductResponse($product)
    {
        $image = $product->image;
        if ($image) {
            // If it's already a full URL, use it. Otherwise, construct it.
            if (!str_starts_with($image, 'http')) {
                // Ensure the path is correct after the storage/ relative to public/
                $cleanPath = ltrim($image, '/');
                $image = "http://10.10.10.203:8000/storage/" . $cleanPath;
            }
        }

        return [
            'id' => (int) $product->pid,
            'name' => $product->name,
            'description' => $product->description,
            'price' => $product->price,
            'stock' => (int) $product->stock,
            'image' => $image,
            'category' => $product->category ? [
                'id' => (int) $product->category->id,
                'name' => $product->category->name,
            ] : null,
            'created_at' => $product->created_at,
            'updated_at' => $product->updated_at,
            'cid' => (int) $product->cid,
        ];
    }

    public function destroy(string $pid)
    {
        $product = Product::find($pid);
        if (!$product) return response()->json(['message' => 'Product not found'], 404);
        if ($product->image) {
            $imagePath = $this->normalizeStoredImagePath($product->image);
            Storage::disk('public')->delete($imagePath);
        }
        $product->delete();
        return response()->json(['message' => 'Product deleted successfully'], 200);
    }

    public function getImage($pid)
    {
        $product = Product::find($pid);
        if (!$product || !$product->image) return response()->json(['message' => 'Image not found'], 404);

        $imagePath = $this->normalizeStoredImagePath($product->image);
        $path = storage_path('app/public/' . $imagePath);
        if (!file_exists($path)) return response()->json(['message' => 'Image file not found'], 404);

        // Flutter Web loads network images with CORS enabled; add permissive headers.
        return response()->file($path, [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => '*',
            'Cache-Control' => 'no-cache, must-revalidate',
        ]);
    }

    protected function storeImage($image)
    {
        $extension = $image->getClientOriginalExtension();
        if (empty($extension)) {
            $extension = $image->guessExtension() ?? 'bin';
        }
        $imageName = time() . '_' . uniqid() . '.' . $extension;
        $image->storeAs('products', $imageName, 'public');
        // Store just the relative path from storage/app/public/
        return 'products/' . $imageName;
    }

    protected function normalizeStoredImagePath(string $image): string
    {
        // Accept values like:
        // - "products/file.png"
        // - "/storage/products/file.png"
        // - "http://host/storage/products/file.png"
        $path = $image;

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            $parsed = parse_url($path, PHP_URL_PATH);
            $path = is_string($parsed) ? $parsed : '';
        }

        if (str_starts_with($path, '/storage/')) {
            $path = substr($path, strlen('/storage/'));
        }

        return ltrim($path, '/');
    }

}
