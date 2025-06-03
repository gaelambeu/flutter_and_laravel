<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Subscription extends Model
{
    protected $fillable = [
        'email',
        'google_id',
        'prix',
        'status',
        'account',
        'type_account',
        'expire_date',
        'jours',
    ];

    protected $casts = [
        'expire_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'email', 'email');
    }

    public function getIsActiveAttribute()
    {
        return $this->expire_date && $this->expire_date->isFuture();
    }

    public function updateSubscription(int $days)
    {
        if (!$this->expire_date || !$this->isActive) {
            $this->expire_date = now();
        }

        $this->expire_date = $this->expire_date->addDays($days);
        $this->jours = Carbon::now()->diffInDays($this->expire_date, false); // Enregistre les jours restants
        $this->save();
    }
}
