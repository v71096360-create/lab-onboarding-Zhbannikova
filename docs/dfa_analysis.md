# Анализ потоков данных (DFA)

## Исходный код:

```python
def process_transaction(user_id, amount, db_connection):
    log_entry = "Start processing"
    if amount > 0:
        status = "approved"
        balance = get_balance(user_id)
        new_balance = balance - amount
        update_balance(user_id, new_balance)
    log_entry = "Transaction finished with status: " + status
    file = open("audit_log.txt", "w")
    file.write(log_entry)
    return status



## Def-Use цепочки

### Переменная: log_entry
- **Def:** строка 7 (`log_entry = "Start processing"`)
- **Def (переопределение):** строка 13 (`log_entry = "Transaction finished..."`)
- **Use:** строка 15 (`file.write(log_entry)`)
- **Первое значение ("Start processing") никогда не читается!**

### Переменная: status
- **Def:** строка 9 (`status = "approved"`) — только если `amount > 0`
- **Use:** строка 13 (в конкатенации строки)
- **Use:** строка 16 (`return status`)
- **Если `amount <= 0`, переменная `status` не будет определена!**

### Переменная: balance
- **Def:** строка 10 (`balance = get_balance(user_id)`)
- **Use:** строка 11 (`new_balance = balance - amount`)

### Переменная: new_balance
- **Def:** строка 11 (`new_balance = balance - amount`)
- **Use:** строка 12 (`update_balance(user_id, new_balance)`)

### Переменная: file
- **Def:** строка 14 (`file = open("audit_log.txt", "w")`)
- **Use:** строка 15 (`file.write(log_entry)`)
- **НЕТ ЗАКРЫТИЯ ФАЙЛА!** (отсутствует `file.close()`)

---

## Выявленные дефекты

### Дефект 1: Использование неинициализированной переменной
**Где:** строка 13
**Проблема:** Если `amount <= 0`, то переменная `status` НЕ будет определена в блоке if.
**Ошибка:** При попытке выполнить строку 13 возникнет `UnboundLocalError: local variable 'status' referenced before assignment`

### Дефект 2: Мертвое присваивание (Dead Store)
**Где:** строка 7
**Проблема:** Переменной `log_entry` присваивается значение `"Start processing"`, но на строке 13 это значение ПЕРЕЗАПИСЫВАЕТСЯ без чтения.
**Последствие:** Бесполезная операция, первое значение никогда не используется.

### Дефект 3: Утечка ресурса (Resource Leak)
**Где:** строка 14-15
**Проблема:** Файл открывается (`file = open(...)`), но НИКОГДА не закрывается (`file.close()` не вызывается).
**Последствие:** Файл остается заблокированным, возможны утечки памяти и потеря данных.
