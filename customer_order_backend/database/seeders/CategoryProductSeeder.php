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
        $brands = [
            'Nike' => [
                ['name' => 'Nike Air Max 270', 'price' => 150.00, 'image' => 'products/nike_air_max_270.png', 'desc' => 'Classic Nike Air Max comfort and style.'],
                ['name' => 'Nike Air Force 1', 'price' => 110.00, 'image' => 'products/nike_air_force_1.png', 'desc' => 'Iconic streetwear sneaker.'],
                ['name' => 'Nike Pegasus 40', 'price' => 130.00, 'image' => 'products/nike_pegasus_40.png', 'desc' => 'Responsive road running shoes.'],
                ['name' => 'Nike Dunk Low', 'price' => 115.00, 'image' => 'products/nike_dunk_low.png', 'desc' => 'Versatile and stylish low-top sneaker.'],
            ],
            'Adidas' => [
                ['name' => 'Adidas Samba', 'price' => 110.00, 'image' => 'products/adidas_samba.png', 'desc' => 'Authentic soccer look for the streets.'],
                ['name' => 'Adidas Superstar', 'price' => 95.00, 'image' => 'products/adidas_superstar.png', 'desc' => 'The classic shell-toe shoe.'],
                ['name' => 'Adidas Ultraboost Light', 'price' => 180.00, 'image' => 'products/adidas_ultraboost.png', 'desc' => 'Lightweight energy-returning running shoes.'],
                ['name' => 'Adidas Stan Smith', 'price' => 100.00, 'image' => 'products/adidas_stan_smith.png', 'desc' => 'Timeless tennis-inspired sneakers.'],
            ],
            'New Balance' => [
                ['name' => 'New Balance 550', 'price' => 120.00, 'image' => 'products/nb_550.png', 'desc' => 'Retro basketball-inspired sneaker.'],
                ['name' => 'New Balance 990v6', 'price' => 200.00, 'image' => 'products/nb_990.png', 'desc' => 'Premium comfort and stability.'],
                ['name' => 'New Balance 574', 'price' => 90.00, 'image' => 'products/nb_574.png', 'desc' => 'Classic all-day everyday sneaker.'],
            ],
            'Converse' => [
                ['name' => 'Chuck Taylor All Star', 'price' => 65.00, 'image' => 'products/converse_ctas.png', 'desc' => 'The original basketball shoe.'],
                ['name' => 'Chuck 70 High Top', 'price' => 90.00, 'image' => 'products/converse_c70.png', 'desc' => 'Enhanced cushioning and durability.'],
            ],
            'Puma' => [
                ['name' => 'Puma Suede Classic', 'price' => 75.00, 'image' => 'products/puma_suede.png', 'desc' => 'Iconic low-top silhouette.'],
                ['name' => 'Puma RS-X', 'price' => 110.00, 'image' => 'products/puma_rsx.png', 'desc' => 'Bold bulky design and tech.'],
            ],
        ];

        foreach ($brands as $brandName => $products) {
            $category = Category::updateOrCreate(['name' => $brandName]);

            foreach ($products as $p) {
                Product::updateOrCreate(
                    ['name' => $p['name']],
                    [
                        'name' => $p['name'],
                        'description' => $p['desc'],
                        'price' => $p['price'],
                        'stock' => 50,
                        'image' => $p['image'],
                        'category_id' => $category->id,
                    ]
                );
            }
        }
    }
}
