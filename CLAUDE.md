# Registry Project - Claude Instructions

## Docker Environment

Проект работает ТОЛЬКО в Docker. НИКОГДА не запускай rails/rake/bundle на хост-машине.

### Docker Compose
```bash
cd /Users/oleghasjanov/Documents/registry/registry/docker-images
```

### Запуск тестов
```bash
# Конкретный файл тестов
docker compose exec registry bash -c "cd /opt/webapps/app && rails test test/jobs/check_force_delete_lift_test.rb"

# Конкретный тест по имени
docker compose exec registry bash -c "cd /opt/webapps/app && rails test test/jobs/check_force_delete_lift_test.rb -n test_updates_status_notes_when_invalid_email_changes"

# Несколько файлов
docker compose exec registry bash -c "cd /opt/webapps/app && rails test test/jobs/check_force_delete_lift_test.rb test/models/domain/force_delete_test.rb"

# Вся директория
docker compose exec registry bash -c "cd /opt/webapps/app && rails test test/models/domain/"
```

### Интерактивная консоль
```bash
docker compose exec -it registry bash
# внутри контейнера:
cd /opt/webapps/app
rails test <path>
rails console
```

### Другие команды
```bash
# Rails console
docker compose exec registry bash -c "cd /opt/webapps/app && rails console"

# Rake tasks
docker compose exec registry bash -c "cd /opt/webapps/app && rake <task>"

# Bundle
docker compose exec registry bash -c "cd /opt/webapps/app && bundle <command>"
```

## Project Structure

- Ruby on Rails application (domain registry)
- Test framework: Minitest (test/ directory, NOT spec/)
- Fixtures used instead of factories (test/fixtures/)
- Database schema: db/structure.sql (NOT schema.rb)
