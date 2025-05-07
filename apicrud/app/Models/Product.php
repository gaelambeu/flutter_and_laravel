<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Traits\HasFactor;

class Product extends Model
{
    use HasFactor;

    protected $table = 'products';

    protected $fillable =[
        'name',
        'description',
        'price',
    ];
}
