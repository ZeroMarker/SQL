## Transaction

ACID
- Atomicity
- Consistency
- Isolation
- Durability

begin;      // start a transaction

commit;     // commit transaction

rollback;   // undo

SET AUTOCOMMIT=0    // prevent auto commit

### Isolation

Isolation Level

- Read Uncommitted
- Read Committed
- Repeatable Read // default value
- Serializable

SELECT @@TRANSACTION_ISOLATION

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
