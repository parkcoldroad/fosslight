ALTER TABLE `PROJECT_MASTER`
    ADD `SECMAIL_YN` char(1) DEFAULT 'Y',
    ADD `SECMAIL_DESC` longtext DEFAULT NULL,
    ADD `BINARY_FILE_YN` char(1) DEFAULT NULL;