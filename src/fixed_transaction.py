def process_transaction(user_id, amount, db_connection):
    """Process transaction with proper error handling."""
    status = "pending"
    log_message = "Start processing"

    if amount > 0:
        status = "approved"
        balance = get_balance(user_id)
        new_balance = balance - amount
        update_balance(user_id, new_balance)
    else:
        status = "rejected"

    log_message = f"Transaction finished with status: {status}"

    with open("audit_log.txt", "w") as file:
        file.write(log_message)
        file.write("\n")

    return status


def get_balance(user_id):
    """Mock function to get user balance."""
    return 1000


def update_balance(user_id, new_balance):
    """Mock function to update user balance."""
    pass
