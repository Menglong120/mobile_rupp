<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Product;

class CategoryProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $category = Category::updateOrCreate(
            ['name' => 'Shoes'],
            ['name' => 'Shoes']
        );

        $products = [
            [
                'name' => 'Nike Air Max 270',
                'description' => 'Classic Nike Air Max comfort and style.',
                'price' => 150.00,
                'stock' => 50,
                'image' => 'products/nike_air_max_270.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Nike Air Force 1',
                'description' => 'Iconic streetwear sneaker.',
                'price' => 110.00,
                'stock' => 100,
                'image' => 'products/nike_air_force_1.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Nike Pegasus 40',
                'description' => 'Responsive road running shoes.',
                'price' => 130.00,
                'stock' => 75,
                'image' => 'products/nike_pegasus_40.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Nike Dunk Low',
                'description' => 'Versatile and stylish low-top sneaker.',
                'price' => 115.00,
                'stock' => 60,
                'image' => 'products/nike_dunk_low.png',
                'category_id' => $category->id,
            ],
            // Adidas Products
            [
                'name' => 'Adidas Ultraboost Light',
                'description' => 'Lightweight energy-returning running shoes.',
                'price' => 180.00,
                'stock' => 45,
                'image' => 'products/adidas_ultraboost.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Adidas Stan Smith',
                'description' => 'Timeless tennis-inspired sneakers.',
                'price' => 100.00,
                'stock' => 80,
                'image' => 'products/adidas_stan_smith.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Adidas Superstar',
                'description' => 'The classic shell-toe shoe.',
                'price' => 95.00,
                'stock' => 70,
                'image' => 'products/adidas_superstar.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Adidas Samba',
                'description' => 'Authentic soccer look for the streets.',
                'price' => 110.00,
                'stock' => 30,
                'image' => 'products/adidas_samba.png',
                'category_id' => $category->id,
            ],
        ];

        foreach ($products as $productData) {
            Product::updateOrCreate(
                ['name' => $productData['name']],
                $productData
            );
        }
    }
}
