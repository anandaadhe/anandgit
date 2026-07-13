resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = coalesce(var.bucket_name, "${var.project_name}-website-${random_id.suffix.hex}")
}

resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name

  tags = {
    Name = "${var.project_name}-website"
  }
}

# Static website hosting requires the bucket (and the objects in it) to be
# publicly readable, so we explicitly allow public bucket policies here.
# Free tier: 5 GB standard storage, 20,000 GET and 2,000 PUT/COPY/POST/LIST
# requests per month for the first 12 months. A small static site stays
# comfortably inside those limits.
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Sample page so `terraform apply` gives you an immediately working site.
# Replace/upload your own files afterwards with `aws s3 sync` or more
# aws_s3_object resources.
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-EOF
    <!DOCTYPE html>
    <html>
      <head><title>${var.project_name}</title></head>
      <body>
        <h1>Hello from S3 static website hosting!</h1>
        <p>Bucket: ${local.bucket_name}</p>
      </body>
    </html>
  EOF
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  content_type = "text/html"
  content      = "<!DOCTYPE html><html><body><h1>404 - Not Found</h1></body></html>"
}
