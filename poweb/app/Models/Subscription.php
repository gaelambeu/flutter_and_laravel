<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    protected $fillable = [
        'google_id',
        'prix',
        'status',
        'account',
        'type_account'
        //'demande_unlock'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'google_id', 'google_id');
    }
}
