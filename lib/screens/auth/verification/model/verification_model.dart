class VerificationModel {
  final String title;
  final String subtitle;
  final String verifyButtonText;
  final String resendText;

  const VerificationModel({
    this.title = 'Verify Your Email',
    this.subtitle = 'We\'ve sent a verification link to your email',
    this.verifyButtonText = 'Check Verification Status',
    this.resendText = 'Resend Verification Email',
  });
}
