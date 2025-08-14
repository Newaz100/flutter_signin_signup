# 1️⃣ Delete all migration files except __init__.py
Get-ChildItem -Recurse -Include *.py -Path .\*migrations\* | Where-Object {
    $_.Name -ne "__init__.py"
} | Remove-Item -Force

# 2️⃣ Drop and recreate MySQL database
Write-Host "Dropping and recreating MySQL database..."
mysql -u root -p -e "DROP DATABASE IF EXISTS login_db; CREATE DATABASE login_db;"

# 3️⃣ Make migrations
Write-Host "Running makemigrations..."
python manage.py makemigrations

# 4️⃣ Apply migrations
Write-Host "Running migrate..."
python manage.py migrate

Write-Host "✅ Database reset complete!"
