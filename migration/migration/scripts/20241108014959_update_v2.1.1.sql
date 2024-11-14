-- // update_v2.1.1
-- Migration SQL that makes the change goes here.

ALTER TABLE `OSS_DOWNLOADLOCATION` DROP FULLTEXT INDEX `DOWNLOAD_LOCATION` (DOWNLOAD_LOCATION);
ALTER TABLE `OSS_DOWNLOADLOCATION` ADD INDEX `DOWNLOAD_LOCATION` (DOWNLOAD_LOCATION);

UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT T1.CREATOR, T1.CREATED_DATE, T1.OSS_ID, T1.OSS_NAME, T1.OSS_VERSION,  IFNULL((SELECT GROUP_CONCAT(D.DOWNLOAD_LOCATION ORDER BY D.OSS_DL_IDX ASC) FROM OSS_DOWNLOADLOCATION D WHERE D.OSS_COMMON_ID = T1.OSS_COMMON_ID), T1.DOWNLOAD_LOCATION) AS DOWNLOAD_LOCATION,  IFNULL((SELECT GROUP_CONCAT(D.PURL ORDER BY D.OSS_DL_IDX ASC) FROM OSS_DOWNLOADLOCATION D WHERE D.OSS_COMMON_ID = T1.OSS_COMMON_ID), \'\') AS PURL,  T1.HOMEPAGE, T1.SUMMARY_DESCRIPTION, T1.ATTRIBUTION, T1.COPYRIGHT, T1.LICENSE_TYPE AS OSS_LICENSE_TYPE, T1.OBLIGATION_TYPE AS OSS_OBLIGATION_TYPE, GROUP_CONCAT(T4.OSS_NICKNAME SEPARATOR \'\n\') AS OSS_NICKNAME, T2.LICENSE_ID, T2.OSS_LICENSE_IDX, T2.OSS_LICENSE_COMB, T2.OSS_COPYRIGHT, T2.OSS_LICENSE_TEXT, IF(IFNULL(T3.SHORT_IDENTIFIER, \'\') = \'\', T3.LICENSE_NAME, T3.SHORT_IDENTIFIER) AS LICENSE_NAME, T3.LICENSE_TYPE, SUB1.OSS_TYPE, IFNULL(( SELECT GROUP_CONCAT(IF(LM.SHORT_IDENTIFIER = \'\' OR LM.SHORT_IDENTIFIER IS NULL, LM.LICENSE_NAME, LM.SHORT_IDENTIFIER) ORDER BY OSS_LICENSE_IDX ASC) FROM OSS_LICENSE_DETECTED ODT INNER JOIN LICENSE_MASTER LM ON ODT.LICENSE_ID = LM.LICENSE_ID WHERE ODT.OSS_ID = T1.OSS_ID), \'\') AS DETECTED_LICENSE FROM OSS_MASTER T1 INNER JOIN OSS_LICENSE_DECLARED T2 ON T1.OSS_ID = T2.OSS_ID INNER JOIN LICENSE_MASTER T3 ON T2.LICENSE_ID = T3.LICENSE_ID LEFT OUTER JOIN OSS_NICKNAME T4 ON T1.OSS_COMMON_ID = T4.OSS_COMMON_ID INNER JOIN ( SELECT OSS_ID, CONCAT(IF(MULTI_LICENSE_FLAG = \'N\', \'0\', \'1\'), IF(DUAL_LICENSE_FLAG = \'N\', \'0\', \'1\'), IF(VERSION_DIFF_FLAG = \'N\', \'0\', \'1\')) AS OSS_TYPE FROM OSS_MASTER_LICENSE_FLAG) SUB1 ON T1.OSS_ID = SUB1.OSS_ID WHERE T1.OSS_ID = ? GROUP BY OSS_ID, OSS_LICENSE_IDX' WHERE CD_NO=104 AND CD_DTL_NO=100;

ALTER TABLE `OSS_VERSION` ADD `IMPORTANT_NOTES` MEDIUMTEXT DEFAULT NULL;

ALTER TABLE `OSS_COMMON` DROP COLUMN `CREATOR`;
ALTER TABLE `OSS_COMMON` DROP COLUMN `CREATED_DATE`;
ALTER TABLE `OSS_COMMON` DROP COLUMN `MODIFIER`;
ALTER TABLE `OSS_COMMON` DROP COLUMN `MODIFIED_DATE`;

ALTER TABLE `NVD_DATA_V3`
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`CVE_ID`, `PRODUCT`, `VERSION`, `VENDOR`) USING BTREE;