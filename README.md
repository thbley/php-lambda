## Getting started with PHP on AWS Lambda

```
docker build -t lambda-php-runtime .

docker run --rm --entrypoint /opt/bin/php lambda-php-runtime -v
docker run --rm --entrypoint /opt/bin/php lambda-php-runtime -m
docker run --rm --entrypoint /opt/bin/php lambda-php-runtime -r 'echo 0.7+0.1;'
docker run --rm --entrypoint /opt/bin/php lambda-php-runtime -r 'echo json_encode(0.7+0.1);'

docker run --rm --entrypoint bash lambda-php-runtime -c "cat /opt/bin/php" >bin/php

docker run --rm -v "$PWD":/var/task lambda-php-runtime hello '{"Hello": "bephpug"}'

zip -r runtime.zip bootstrap bin
zip -r vendor.zip vendor/

aws iam create-role \
    --role-name LambdaPhp --path "/service-role/" \
    --assume-role-policy-document file://trust-policy.json

aws lambda publish-layer-version \
    --layer-name php-runtime --region eu-central-1 \
    --zip-file fileb://runtime.zip

aws lambda publish-layer-version \
    --layer-name php-vendor --region eu-central-1 \
    --zip-file fileb://vendor.zip

zip hello.zip src/hello.php

aws lambda create-function --function-name php-hello --handler hello \
    --runtime provided --region eu-central-1 \
    --zip-file fileb://hello.zip \
    --role "arn:aws:iam::<given output from trust-policy upload>" \
    --layers "arn:aws:lambda:<given output from runtime zip upload>" \
                 "arn:aws:lambda:<given output from vendor zip upload" \
                 "arn:aws:lambda:::awslayer:AmazonLinux1803" \
    --memory-size 128 --timeout 5

aws lambda update-function-code --function-name php-hello \
    --zip-file fileb://hello.zip \
    --region eu-central-1

aws lambda invoke --function-name php-hello \
    --region eu-central-1 --log-type Tail --query 'LogResult' \
     --output text --payload '{"Hello": "bephpug"}' \
    output.txt | base64 --decode
```

sources:
- https://github.com/akrabat/lambda-php
- https://hub.docker.com/r/lambci/lambda/
- https://aws.amazon.com/de/blogs/apn/aws-lambda-custom-runtime-for-php-a-practical-example/
- https://en.wikipedia.org/wiki/AWS_Lambda
- https://docs.aws.amazon.com/en_en/lambda/latest/dg/limits.html
- https://www.ec2instances.info
- https://aws.amazon.com/lambda/pricing/
- https://www.trek10.com/blog/lambda-cost/
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Lambda.html
- https://wiki.php.net/rfc/jit
- https://github.com/mk-j/PHP_diseval_extension
- https://tideways.com/profiler/blog/dodge-the-thundering-herd-with-file-based-opcache-in-php7
- https://firecracker-microvm.github.io/
- https://fosdem.org/2019/schedule/event/containers_firecracker/attachments/slides/3188/export/events/attachments/containers_firecracker/slides/3188/Firecracker_as_a_container_runtime_FOSDEM2019_4_3.pdf
- https://aws.amazon.com/blogs/compute/upcoming-updates-to-the-aws-lambda-execution-environment/
