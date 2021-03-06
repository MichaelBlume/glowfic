Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
})
S3_BUCKET = (Aws::S3::Resource.new.bucket(ENV['S3_BUCKET_NAME']) if ENV['S3_BUCKET_NAME'])

Aws::Rails.add_action_mailer_delivery_method(:aws_ses)
