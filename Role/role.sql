-- Role Creation: You can create a role using the CREATE ROLE statement, specifying the desired privileges for that role.

CREATE ROLE role_name;

-- Privilege Assignment: Once a role is created, you can grant privileges to it using the GRANT statement, just like you would for a user.


GRANT SELECT, INSERT, UPDATE ON database_name.* TO role_name;
-- Role Activation: Users can then be granted the role, effectively inheriting its privileges. This is done using the GRANT statement as well.
GRANT role_name TO user_name;

-- Role Usage: Once a user has been granted a role, they can activate it using the SET ROLE statement.
SET ROLE role_name;

-- Revoking Roles: Roles can be revoked from users using the REVOKE statement.
REVOKE role_name FROM user_name;

-- Dropping Roles: You can drop a role when it's no longer needed using the DROP ROLE statement.
DROP ROLE role_name;