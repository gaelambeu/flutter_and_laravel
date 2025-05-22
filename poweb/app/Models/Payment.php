<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'order_id', 'currency', 'amount', 'status', 'track_id',
        'tx_hash', 'address', 'value', 'network', 'description',
        'confirmed_at', 'raw_data'
    ];

    protected $casts = [
        'raw_data' => 'array',
    ];
}
