<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public $otp;
    public $customerName;

    public function __construct($otp, $customerName = null)
    {
        $this->otp = $otp;
        $this->customerName = $customerName;
    }

    public function build()
    {
        return $this->subject('Your Verification Code - Mobile App')
                    ->view('emails.otp');
    }
}
