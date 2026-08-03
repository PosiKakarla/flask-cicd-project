resource "aws_ecr_repository" "flask_cicd_app" {
    name                 = "flask-cicd-app"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}

output "ecr_repository_url" {
    value = aws_ecr_repository.flask_cicd_app.repository_url
}

