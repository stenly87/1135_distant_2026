## «Система инвентаризационного учёта оборудования на предприятии»  
**Дата актуализации:** 10 февраля 2026 г.  
**Технологический стек:** C# 12, JetBrains Rider, Avalonia UI 11.1, ASP.NET Core 8 Web API, MySQL 8.0  
**Уровень:** Продвинутый (full-stack .NET-разработка с акцентом на архитектуру и безопасность)

---

## 🎯 ЦЕЛЬ ЗАДАНИЯ
Разработать систему с разделением ролей (бухгалтер/сотрудник), безопасной аутентификацией (JWT), бизнес-логикой учёта оборудования и гибкой отчётностью. Акцент на:
- Чистую архитектуру (слои, зависимости)
- Валидацию на всех уровнях
- Обработку крайних случаев
- Безопасность данных
- UX для конечных пользователей

---

## 🗃️ ЧАСТЬ 1: БАЗА ДАННЫХ (MySQL)

### База данных едина для всех, сервер 192.168.200.13, 1135_inventory_system

База пустая, можно добавить данные по мере разработки
---

## 🌐 ЧАСТЬ 2: WEB API — ПОЛНЫЙ НАБОР ЭНДПОИНТОВ

### Структура проекта
```
Inventory.API/
├── Controllers/
│   ├── AuthController.cs
│   ├── UsersController.cs
│   ├── EquipmentController.cs
│   ├── AssignmentsController.cs
│   ├── InventoryController.cs
│   ├── ReportsController.cs
│   └── DashboardController.cs
├── Services/ (IAuthService, IEquipmentService...)
├── Models/
│   ├── DTO/ (Request/Response объекты)
│   ├── Entities/ (EF Core модели)
│   └── Enums/
├── Middleware/ (GlobalExceptionHandling)
├── Data/ (AppDbContext)
└── appsettings.json (JWT, DB, CORS)
```

### 📜 ДЕТАЛИЗИРОВАННЫЕ ЭНДПОИНТЫ

#### 🔒 **AuthController** (`[AllowAnonymous]`)
| Метод | Путь | Тело | Ответ | Описание |
|-------|------|------|-------|----------|
| `POST` | `/api/auth/login` | `{username, password}` | `{token, userId, role, fullName, expiresIn}` | Аутентификация |
| `POST` | `/api/auth/change-password` | `{oldPassword, newPassword}` | `200 OK` | Смена пароля |
| `GET` | `/api/auth/validate` | — | `{isValid: true}` | Проверка валидности токена |

#### 👥 **UsersController** (`[Authorize(Roles = "Accountant")]`)
| Метод | Путь | Описание |
|-------|------|----------|
| `GET` | `/api/users` | Список всех пользователей (без паролей) |
| `GET` | `/api/users/employees` | Только активные сотрудники (для выпадающих списков) |
| `POST` | `/api/users` | Создание пользователя (валидация уникальности) |
| `PUT` | `/api/users/{id}/deactivate` | Деактивация учётной записи |
| `GET` | `/api/users/me` | Данные текущего пользователя |

#### 🖥️ **EquipmentController**
| Метод | Путь | Роль | Описание |
|-------|------|------|----------|
| `GET` | `/api/equipment` | Accountant | Все оборудование + пагинация (`?page=1&pageSize=20&status=...`) |
| `GET` | `/api/equipment/available` | Accountant | Только доступное для выдачи |
| `GET` | `/api/equipment/my` | Employee | Оборудование, назначенное текущему сотруднику |
| `GET` | `/api/equipment/{id}` | Все | Детали + история назначений |
| `POST` | `/api/equipment` | Accountant | Создание (валидация уникальности InventoryNumber) |
| `PUT` | `/api/equipment/{id}` | Accountant | Редактирование (запрет изменения InventoryNumber) |
| `PATCH` | `/api/equipment/{id}/status` | Accountant | Изменение статуса |
| `DELETE` | `/api/equipment/{id}` | Accountant | Мягкое удаление (IsActive = false) |

#### 🔄 **AssignmentsController** (`[Authorize]`)
| Метод | Путь | Тело | Описание |
|-------|------|------|----------|
| `POST` | `/api/assignments` | `{equipmentId, employeeId, reason}` | Выдача оборудования (валидация: статус=Available, лимит на сотрудника) |
| `POST` | `/api/assignments/{id}/return` | `{reason}` | Возврат оборудования |
| `GET` | `/api/assignments/history` | `?equipmentId=...&employeeId=...` | История назначений |
| `GET` | `/api/assignments/current` | — | Текущие назначения (для отчётов) |

#### 📋 **InventoryController**
| Метод | Путь | Роль | Описание |
|-------|------|------|----------|
| `GET` | `/api/inventory/my` | Employee | История инвентаризаций текущего сотрудника |
| `GET` | `/api/inventory/equipment/{id}` | Accountant | История по оборудованию |
| `POST` | `/api/inventory` | Employee | Создание записи (валидация: оборудование назначено пользователю, не чаще 1 раза в 24ч) |
| `PUT` | `/api/inventory/{id}/correct` | Accountant | Корректировка записи (с причиной) |

#### 📊 **ReportsController** (`[Authorize(Roles = "Accountant")]`)
| Метод | Путь | Параметры | Описание |
|-------|------|-----------|----------|
| `GET` | `/api/reports/inventory-summary` | `?employeeId=...&startDate=...&endDate=...` | Сводка по инвентаризациям |
| `GET` | `/api/reports/missing-equipment` | `?includeResolved=false` | Оборудование с последней инвентаризацией IsPresent=false |
| `GET` | `/api/reports/equipment-status` | — | Распределение по статусам (для диаграмм) |
| `GET` | `/api/reports/assignment-history` | `?startDate=...&endDate=...` | Детальная история назначений |
| `POST` | `/api/reports/export` | `{type: "PDF"|"Excel", ...}` | Генерация отчёта (возвращает файл) |

#### 📌 **DashboardController**
| Метод | Путь | Роль | Описание |
|-------|------|------|----------|
| `GET` | `/api/dashboard/accountant` | Accountant | Сводка: доступное/назначенное оборудование, просроченные инвентаризации |
| `GET` | `/api/dashboard/employee` | Employee | Сводка: кол-во оборудования, даты следующей инвентаризации |

### 🔐 КРИТИЧЕСКИЕ БИЗНЕС-ПРАВИЛА В API
```csharp
// Пример: При создании записи инвентаризации
if (!record.IsPresent) 
    equipment.Status = EquipmentStatus.Missing;
else if (record.Condition == EquipmentCondition.Unusable)
    equipment.Status = EquipmentStatus.UnderRepair;
    
equipment.LastInventoryDate = DateTime.UtcNow;
await _context.InventoryRecords.AddAsync(record);
await _context.SaveChangesAsync();

// Пример: При выдаче оборудования
if (equipment.Status != EquipmentStatus.Available) 
    throw new ConflictException("Оборудование недоступно для выдачи");
    
var currentAssignments = await _context.Equipment
    .CountAsync(e => e.AssignedToUserId == employeeId && e.IsActive);
if (currentAssignments >= maxLimit) 
    throw new BadRequestException($"Превышен лимит оборудования ({maxLimit})");
```

### ⚙️ ТЕХНИЧЕСКИЕ ДЕТАЛИ API
- **JWT:** lifetime = 2 часа, подпись через секрет из `appsettings.json`, refresh token — опционально
- **Безопасность:** 
  - Все пароли хешируются через BCrypt.Net
  - Параметризованные запросы (EF Core)
  - Rate limiting (100 запросов/мин на пользователя)
  - CORS: только доверенные источники
- **Обработка ошибок:** Глобальный мидлварь с кодами:
  - `400` — валидация
  - `401` — неавторизован
  - `403` — нет прав
  - `404` — не найдено
  - `409` — конфликт (например, оборудование уже назначено)
  - `422` — бизнес-ошибка
  - `500` — внутренняя ошибка

---

## 💻 ЧАСТЬ 3: AVALONIA UI (MVVM)

### Структура проекта
```
Inventory.Client/
├── Views/
│   ├── LoginView.axaml
│   ├── AccountantMainWindow.axaml (вкладки: Оборудование, Назначения, Отчёты, Дашборд)
│   └── EmployeeMainWindow.axaml (вкладки: Моё оборудование, Инвентаризация, История)
├── ViewModels/ (LoginVM, EquipmentVM, InventoryVM...)
├── Models/ (DTO для отображения)
├── Services/
│   ├── ApiService.cs (HttpClient + автоматическая подстановка токена)
│   ├── AuthService.cs (хранение токена в памяти, проверка срока)
│   ├── NavigationService.cs
│   └── DialogService.cs (универсальные диалоги)
├── Converters/ (для привязок: статус → цвет и т.д.)
├── Assets/ (иконки, темы)
└── App.axaml.cs (определение роли после логина)
```

### 🖥️ ФУНКЦИОНАЛ ПО РОЛЯМ

#### 👔 **Бухгалтер**
- **Дашборд:** Карты с ключевыми метриками (доступное оборудование, просроченные инвентаризации)
- **Оборудование:** 
  - DataGrid с фильтрацией, сортировкой, пагинацией
  - Форма добавления/редактирования с валидацией
  - Кнопки "Выдать", "Изменить статус"
- **Назначения:** 
  - Выбор оборудования из списка доступного
  - Выбор сотрудника из выпадающего списка
  - Указание причины
- **Отчёты:**
  - Гибкие фильтры (сотрудник, период)
  - Таблица результатов
  - Кнопки экспорта в PDF (QuestPDF) / Excel (ClosedXML)

#### 👷 **Сотрудник**
- **Дашборд:** Список оборудования в подотчёте, напоминания об инвентаризации
- **Моё оборудование:** 
  - Список с колонками: Инв. номер, Наименование, Дата выдачи, Статус
  - Кнопка "Провести инвентаризацию" (активна только для статуса Assigned)
- **Инвентаризация:**
  - Модальное окно с полями:
    - Состояние (ComboBox)
    - Чекбокс "Присутствует"
    - Местоположение (текст)
    - Комментарий (многострочный)
    - Кнопка "Прикрепить фото" (FilePicker → загрузка на сервер)
  - Автоматическая блокировка повторной инвентаризации в течение 24 часов
- **История:** Таблица проведённых инвентаризаций (только чтение)

### ⚙️ ТЕХНИЧЕСКИЕ ДЕТАЛИ КЛИЕНТА
- **Хранение токена:** В памяти (`AuthService`), очистка при выходе или закрытии приложения
- **Обработка ошибок:** 
  - При 401 — автоматический редирект на логин
  - Понятные пользователю сообщения (не "500 Internal Server Error")
- **Асинхронность:** Все вызовы API через `async/await`, индикаторы загрузки
- **Локализация:** Русский язык (ресурсы в `Resources.resx`)
- **Стилизация:** Тема Fluent, адаптивные макеты, иконки через `Avalonia.Themes.Fluent`
- **Валидация:** Отображение ошибок в UI при невалидных данных

---


### 🔑 КЛЮЧЕВЫЕ СЦЕНАРИИ
1. **Выдача оборудования бухгалтером:**
   - Проверка статуса оборудования → создание записи в `AssignmentHistory` → обновление `Equipment.AssignedToUserId` и `Status`
2. **Инвентаризация сотрудником:**
   - Валидация: оборудование назначено пользователю + не инвентаризовалось последние 24ч → создание записи → обновление статуса оборудования при необходимости
3. **Формирование отчёта:**
   - JOIN Equipment, InventoryRecords, Users → агрегация данных → возврат структурированного JSON → экспорт в PDF/Excel на клиенте

---

## 📎 ДОПОЛНИТЕЛЬНЫЕ РЕКОМЕНДАЦИИ

### 🔒 Безопасность
- **API:** 
  - Параметризованные запросы (защита от SQL Injection)
  - Валидация всех входных данных
  - Логирование подозрительных действий (много неудачных логинов)
- **Клиент:** 
  - Токен хранится ТОЛЬКО в памяти (никаких файлов!)
  - Очистка токена при закрытии приложения
  - HTTPS в продакшене (в учебных целях — HTTP с пометкой)


  # 📄 ПРИМЕРЫ ГЕНЕРАЦИИ ОТЧЁТОВ  
*(Рекомендуется реализация на стороне сервера — безопаснее и масштабируемее)*

---

## 📄 ПРИМЕР 1: ГЕНЕРАЦИЯ PDF НА СЕРВЕРЕ (ASP.NET Core + QuestPDF)

### 📦 Установка пакетов
```bash
dotnet add package QuestPDF
dotnet add package QuestPDF.Helpers
dotnet add package QuestPDF.Fluent
```

### 💻 Код контроллера (`ReportsController.cs`)
```csharp
[HttpPost("export")]
[Authorize(Roles = "Accountant")]
public async Task<IActionResult> ExportReport([FromBody] ExportRequest request)
{
    if (request.Type != "PDF") 
        return BadRequest("Поддерживается только тип 'PDF' для этого метода");
    
    // Получаем данные отчёта из сервиса
    var reportData = await _reportService.GetInventorySummaryAsync(
        request.EmployeeId, 
        request.StartDate, 
        request.EndDate
    );
    
    // Генерируем PDF в памяти
    var document = Document.Create(container =>
    {
        container.Page(page =>
        {
            page.Size(PageSizes.A4);
            page.Margin(2, Unit.Centimetre);
            page.DefaultTextStyle(x => x.FontSize(10));
            
            page.Header().Element(ComposeHeader);
            page.Content().Element(ComposeContent);
            page.Footer().AlignCenter().Text(text =>
            {
                text.Span("Страница ");
                text.CurrentPageNumber();
                text.Span(" из ");
                text.TotalPages();
            });
        });
    });
    
    using var stream = new MemoryStream();
    document.GeneratePdf(stream);
    stream.Position = 0;
    
    var fileName = $"InventoryReport_{DateTime.Now:yyyyMMdd_HHmmss}.pdf";
    return File(stream.ToArray(), "application/pdf", fileName);
    
    // --- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ---
    void ComposeHeader(IContainer container)
    {
        container.Row(row =>
        {
            row.RelativeItem().Column(col =>
            {
                col.Item().Text("СИСТЕМА ИНВЕНТАРИЗАЦИОННОГО УЧЁТА").FontSize(16).Bold();
                col.Item().Text($"Период: {request.StartDate:dd.MM.yyyy} - {request.EndDate:dd.MM.yyyy}")
                    .FontSize(10).FontColor(QuestPDF.Helpers.Colors.Grey.Medium);
                if (request.EmployeeId.HasValue)
                    col.Item().Text($"Сотрудник: {reportData.EmployeeName}").FontSize(10);
            });
            row.ConstantItem(80).Height(60).Placeholder(); // Логотип (опционально)
        });
    }
    
    void ComposeContent(IContainer container)
    {
        container.PaddingVertical(10).Column(col =>
        {
            // Сводка
            col.Item().Component<SummaryBox>(reportData.TotalEquipment, "Всего оборудования");
            col.Item().Component<SummaryBox>(reportData.InventoriedCount, "Проверено");
            col.Item().Component<SummaryBox>(reportData.MissingCount, "Отсутствует", true);
            
            // Таблица инвентаризаций
            col.Item().PaddingTop(15).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(); // Инв. номер
                    columns.RelativeColumn(); // Наименование
                    columns.ConstantColumn(100); // Состояние
                    columns.ConstantColumn(80);  // Присутствует
                    columns.ConstantColumn(100); // Дата
                });
                
                // Заголовок таблицы
                table.Header(header =>
                {
                    header.Cell().Element(CellStyle).Text("Инв. номер").Bold();
                    header.Cell().Element(CellStyle).Text("Наименование").Bold();
                    header.Cell().Element(CellStyle).Text("Состояние").Bold();
                    header.Cell().Element(CellStyle).Text("Присутствует").Bold();
                    header.Cell().Element(CellStyle).Text("Дата").Bold();
                });
                
                // Данные
                foreach (var item in reportData.Details)
                {
                    table.Cell().Element(CellStyle).Text(item.InventoryNumber);
                    table.Cell().Element(CellStyle).Text(item.EquipmentName);
                    table.Cell().Element(CellStyle).Text(item.Condition)
                        .FontColor(item.Condition == "Unusable" ? Colors.Red.Medium : Colors.Green.Dark);
                    table.Cell().Element(CellStyle).Text(item.IsPresent ? "Да" : "НЕТ")
                        .FontColor(item.IsPresent ? Colors.Green.Dark : Colors.Red.Medium).Bold();
                    table.Cell().Element(CellStyle).Text(item.InventoryDate.ToString("dd.MM.yyyy"));
                }
            });
            
            // Подпись
            col.Item().PaddingTop(20).AlignRight().Text($"Сформировано: {DateTime.Now:dd.MM.yyyy HH:mm}")
                .FontSize(9).FontColor(Colors.Grey.Medium);
        });
    }
    
    // Стиль ячейки таблицы
    static IContainer CellStyle(IContainer container) => 
        container.BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).AlignCenter();
});

// Вспомогательный компонент для сводки
internal class SummaryBox : IComponent
{
    private readonly int _value;
    private readonly string _label;
    private readonly bool _isCritical;
    
    public SummaryBox(int value, string label, bool isCritical = false)
    {
        _value = value; _label = label; _isCritical = isCritical;
    }
    
    public void Compose(IContainer container)
    {
        container
            .Border(1)
            .BorderColor(_isCritical ? Colors.Red.Medium : Colors.Blue.Medium)
            .Background(_isCritical ? Colors.Red.Lighten4 : Colors.Blue.Lighten4)
            .Padding(8)
            .Width(150)
            .Column(col =>
            {
                col.Item().Text(_value.ToString()).FontSize(24).Bold()
                    .FontColor(_isCritical ? Colors.Red.Dark : Colors.Blue.Dark);
                col.Item().Text(_label).FontSize(10).FontColor(Colors.Grey.Dark);
            });
    }
}
```

### 📥 Вызов из Avalonia (ApiService.cs)
```csharp
public async Task<byte[]> ExportReportAsync(ExportRequest request)
{
    var response = await _httpClient.PostAsJsonAsync("api/reports/export", request);
    response.EnsureSuccessStatusCode();
    return await response.Content.ReadAsByteArrayAsync();
}

// Сохранение через диалог
public async Task SaveReportAsync(byte[] fileBytes, string defaultName)
{
    var dialog = new SaveFileDialog
    {
        Title = "Сохранить отчёт",
        InitialFileName = defaultName,
        Filters = new List<FileDialogFilter>
        {
            new() { Name = "PDF Document", Extensions = new List<string> { "pdf" } }
        }
    };
    
    var path = await dialog.ShowAsync(MainWindow.Instance);
    if (!string.IsNullOrEmpty(path))
        await File.WriteAllBytesAsync(path, fileBytes);
}
```

---

## 📊 ПРИМЕР 2: ГЕНЕРАЦИЯ EXCEL НА СЕРВЕРЕ (ASP.NET Core + ClosedXML)

### 📦 Установка пакетов
```bash
dotnet add package ClosedXML
dotnet add package DocumentFormat.OpenXml
```

### 💻 Код контроллера (`ReportsController.cs`)
```csharp
[HttpPost("export-excel")]
[Authorize(Roles = "Accountant")]
public async Task<IActionResult> ExportExcel([FromBody] ExportRequest request)
{
    var reportData = await _reportService.GetInventorySummaryAsync(
        request.EmployeeId, 
        request.StartDate, 
        request.EndDate
    );
    
    using var workbook = new XLWorkbook();
    var worksheet = workbook.Worksheets.Add("Инвентаризация");
    
    // Заголовок отчёта
    worksheet.Cell(1, 1).Value = "ОТЧЁТ ПО ИНВЕНТАРИЗАЦИИ ОБОРУДОВАНИЯ";
    worksheet.Range(1, 1, 1, 6).Merge().Style
        .Font.SetBold().FontSize = 14
        .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center)
        .Fill.SetBackgroundColor(XLColor.FromArgb(42, 113, 192)); // Синий фон
    
    // Период и сотрудник
    worksheet.Cell(2, 1).Value = $"Период: {request.StartDate:dd.MM.yyyy} - {request.EndDate:dd.MM.yyyy}";
    if (request.EmployeeId.HasValue)
        worksheet.Cell(3, 1).Value = $"Сотрудник: {reportData.EmployeeName}";
    
    // Заголовки таблицы (начиная с 5-й строки)
    var headers = new[]
    {
        "Инв. номер", "Наименование", "Категория", 
        "Состояние", "Присутствует", "Дата инвентаризации", "Местоположение"
    };
    
    for (int i = 0; i < headers.Length; i++)
    {
        worksheet.Cell(5, i + 1).Value = headers[i];
        worksheet.Cell(5, i + 1).Style
            .Font.SetBold()
            .Fill.SetBackgroundColor(XLColor.LightGray)
            .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
    }
    
    // Данные
    int row = 6;
    foreach (var item in reportData.Details)
    {
        worksheet.Cell(row, 1).Value = item.InventoryNumber;
        worksheet.Cell(row, 2).Value = item.EquipmentName;
        worksheet.Cell(row, 3).Value = item.Category;
        worksheet.Cell(row, 4).Value = item.Condition;
        
        // Условное форматирование для "Присутствует"
        var presentCell = worksheet.Cell(row, 5);
        presentCell.Value = item.IsPresent ? "Да" : "НЕТ";
        presentCell.Style.Font.SetBold();
        presentCell.Style.Font.FontColor = 
            item.IsPresent ? XLColor.Green : XLColor.Red;
        
        worksheet.Cell(row, 6).Value = item.InventoryDate;
        worksheet.Cell(row, 6).Style.DateFormat.Format = "dd.mm.yyyy";
        worksheet.Cell(row, 7).Value = item.Location;
        
        row++;
    }
    
    // Автоширина колонок
    worksheet.Columns().AdjustToContents();
    
    // Сводка в отдельном блоке
    worksheet.Cell(row + 2, 1).Value = "СВОДКА:";
    worksheet.Cell(row + 3, 1).Value = "Всего оборудования:";
    worksheet.Cell(row + 3, 2).Value = reportData.TotalEquipment;
    worksheet.Cell(row + 4, 1).Value = "Проверено:";
    worksheet.Cell(row + 4, 2).Value = reportData.InventoriedCount;
    worksheet.Cell(row + 5, 1).Value = "Отсутствует:";
    worksheet.Cell(row + 5, 2).Value = reportData.MissingCount;
    worksheet.Cell(row + 5, 2).Style.Font.FontColor = XLColor.Red;
    
    // Сохранение в MemoryStream
    using var stream = new MemoryStream();
    workbook.SaveAs(stream);
    stream.Position = 0;
    
    var fileName = $"Inventory_{(request.EmployeeId.HasValue ? $"Emp{request.EmployeeId}" : "All")}_{DateTime.Now:yyyyMMdd}.xlsx";
    return File(stream.ToArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
}
```

### 📥 Вызов из Avalonia (ApiService.cs)
```csharp
public async Task<byte[]> ExportExcelAsync(ExportRequest request)
{
    var response = await _httpClient.PostAsJsonAsync("api/reports/export-excel", request);
    response.EnsureSuccessStatusCode();
    return await response.Content.ReadAsByteArrayAsync();
}

// Сохранение через диалог
public async Task SaveExcelAsync(byte[] fileBytes)
{
    var dialog = new SaveFileDialog
    {
        Title = "Сохранить Excel-отчёт",
        InitialFileName = $"Inventory_{DateTime.Now:yyyyMMdd_HHmm}.xlsx",
        Filters = new List<FileDialogFilter>
        {
            new() { Name = "Excel Workbook", Extensions = new List<string> { "xlsx" } }
        }
    };
    
    var path = await dialog.ShowAsync(MainWindow.Instance);
    if (!string.IsNullOrEmpty(path))
        await File.WriteAllBytesAsync(path, fileBytes);
}
```

---

## 🔑 КЛЮЧЕВЫЕ ПРЕИМУЩЕСТВА СЕРВЕРНОЙ ГЕНЕРАЦИИ
| Критерий | Серверная генерация | Клиентская генерация |
|----------|---------------------|----------------------|
| **Безопасность** | ✅ Данные не уходят на клиент | ❌ Все данные передаются клиенту |
| **Производительность** | ✅ Сервер оптимизирован для обработки | ❌ Нагрузка на клиентское устройство |
| **Согласованность** | ✅ Единый формат для всех | ❌ Зависит от ОС/устройства клиента |
| **Поддержка** | ✅ Легко изменить шаблон | ❌ Требует обновления клиентского приложения |
| **Зависимости** | ✅ Только на сервере | ❌ Увеличение размера клиентского приложения |

---

## 💡 ДОПОЛНИТЕЛЬНЫЕ РЕКОМЕНДАЦИИ
1. **Для PDF:**
   - Добавьте логотип предприятия через `Image.FromFile()` в QuestPDF
   - Реализуйте разбивку на страницы для больших отчётов
   - Используйте `document.GeneratePdfToFile(path)` для отладки

2. **Для Excel:**
   - Добавьте сводные таблицы через `worksheet.PivotTables.Add(...)`
   - Внедрите условное форматирование для критичных значений
   - Создайте отдельный лист с графиками (требует ClosedXML.Charting)

3. **Важно для продакшена:**
   ```csharp
   // В Program.cs добавьте ограничение размера запроса
   builder.Services.Configure<IISServerOptions>(options => 
   {
       options.MaxRequestBodySize = 10 * 1024 * 1024; // 10 МБ
   });
   ```
   ```csharp
   // Валидация параметров экспорта
   if (request.EndDate - request.StartDate > TimeSpan.FromDays(365))
       return BadRequest("Период не может превышать 1 год");
   ```
