<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'track_id', 'status', 'type', 'module_name', 'amount', 'value',
        'currency', 'order_id', 'email', 'note', 'fee_paid_by_payer',
        'under_paid_coverage', 'description', 'paid_at', 'raw_data'
    ];

    protected $casts = [
        'fee_paid_by_payer' => 'boolean',
        'under_paid_coverage' => 'decimal:8',
        'paid_at' => 'datetime',
        'raw_data' => 'array',
    ];
}
