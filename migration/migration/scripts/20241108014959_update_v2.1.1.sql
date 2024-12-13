-- // update_v2.1.1
-- Migration SQL that makes the change goes here.

ALTER TABLE `OSS_DOWNLOADLOCATION` DROP INDEX `DOWNLOAD_LOCATION`;
ALTER TABLE `OSS_DOWNLOADLOCATION` ADD INDEX `DOWNLOAD_LOCATION`(`DOWNLOAD_LOCATION`);

UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT T1.CREATOR, T1.CREATED_DATE, T1.OSS_ID, T1.OSS_NAME, T1.OSS_VERSION,  IFNULL((SELECT GROUP_CONCAT(D.DOWNLOAD_LOCATION ORDER BY D.OSS_DL_IDX ASC) FROM OSS_DOWNLOADLOCATION D WHERE D.OSS_COMMON_ID = T1.OSS_COMMON_ID), T1.DOWNLOAD_LOCATION) AS DOWNLOAD_LOCATION,  IFNULL((SELECT GROUP_CONCAT(D.PURL ORDER BY D.OSS_DL_IDX ASC) FROM OSS_DOWNLOADLOCATION D WHERE D.OSS_COMMON_ID = T1.OSS_COMMON_ID), \'\') AS PURL,  T1.HOMEPAGE, T1.SUMMARY_DESCRIPTION, T1.ATTRIBUTION, T1.COPYRIGHT, T1.LICENSE_TYPE AS OSS_LICENSE_TYPE, T1.OBLIGATION_TYPE AS OSS_OBLIGATION_TYPE, GROUP_CONCAT(T4.OSS_NICKNAME SEPARATOR \'\n\') AS OSS_NICKNAME, T2.LICENSE_ID, T2.OSS_LICENSE_IDX, T2.OSS_LICENSE_COMB, T2.OSS_COPYRIGHT, T2.OSS_LICENSE_TEXT, IF(IFNULL(T3.SHORT_IDENTIFIER, \'\') = \'\', T3.LICENSE_NAME, T3.SHORT_IDENTIFIER) AS LICENSE_NAME, T3.LICENSE_TYPE, SUB1.OSS_TYPE, IFNULL(( SELECT GROUP_CONCAT(IF(LM.SHORT_IDENTIFIER = \'\' OR LM.SHORT_IDENTIFIER IS NULL, LM.LICENSE_NAME, LM.SHORT_IDENTIFIER) ORDER BY OSS_LICENSE_IDX ASC) FROM OSS_LICENSE_DETECTED ODT INNER JOIN LICENSE_MASTER LM ON ODT.LICENSE_ID = LM.LICENSE_ID WHERE ODT.OSS_ID = T1.OSS_ID), \'\') AS DETECTED_LICENSE FROM OSS_MASTER T1 INNER JOIN OSS_LICENSE_DECLARED T2 ON T1.OSS_ID = T2.OSS_ID INNER JOIN LICENSE_MASTER T3 ON T2.LICENSE_ID = T3.LICENSE_ID LEFT OUTER JOIN OSS_NICKNAME T4 ON T1.OSS_COMMON_ID = T4.OSS_COMMON_ID INNER JOIN ( SELECT OSS_ID, CONCAT(IF(MULTI_LICENSE_FLAG = \'N\', \'0\', \'1\'), IF(DUAL_LICENSE_FLAG = \'N\', \'0\', \'1\'), IF(VERSION_DIFF_FLAG = \'N\', \'0\', \'1\')) AS OSS_TYPE FROM OSS_MASTER_LICENSE_FLAG) SUB1 ON T1.OSS_ID = SUB1.OSS_ID WHERE T1.OSS_ID = ? GROUP BY OSS_ID, OSS_LICENSE_IDX' WHERE CD_NO=104 AND CD_DTL_NO=100;

ALTER TABLE `OSS_COMMON` ADD `IMPORTANT_NOTES` MEDIUMTEXT DEFAULT NULL;

ALTER TABLE `NVD_DATA_V3`
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`CVE_ID`, `PRODUCT`, `VERSION`, `VENDOR`) USING BTREE;
	
-- replace oss_master view table
CREATE OR REPLACE VIEW OSS_MASTER 
AS
SELECT
	OV.OSS_ID,
   OC.OSS_COMMON_ID,
   OC.OSS_NAME,
   OV.OSS_VERSION,
   OC.HOMEPAGE,
	OC.DOWNLOAD_LOCATION,
   OC.SUMMARY_DESCRIPTION,
   OV.LICENSE_DIV,
   OV.USE_YN,
   OV.VULN_CPE_NM,
   OV.CVSS_SCORE,
   OV.CVE_ID,
   OV.VULN_YN,
   OV.VULN_RECHECK,
   OV.VULN_DATE,
   OV.LICENSE_TYPE,
   OV.OBLIGATION_TYPE,
   OV.COPYRIGHT,
   OV.ATTRIBUTION,
	OC.DEACTIVATE_FLAG,
	OV.CREATOR,
	OV.CREATED_DATE,
	OV.MODIFIER,
	OV.MODIFIED_DATE,
	OV.RESTRICTION,
	OC.IMPORTANT_NOTES,
	OV.IN_CPE_MATCH_FLAG
FROM OSS_COMMON OC
INNER JOIN OSS_VERSION OV
ON OC.OSS_COMMON_ID = OV.OSS_COMMON_ID;

UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT RTN.OSS_ID, RTN.OSS_NAME, RTN.OSS_VERSION, RTN.CVSS_SCORE, RTN.CVE_ID, RTN.VULN_SUMMARY, RTN.MODI_DATE, RTN.PUBL_DATE FROM ( SELECT T2.OSS_ID, T2.OSS_NAME, T2.OSS_VERSION, T4.CVSS_SCORE, T4.CVE_ID, T5.VULN_SUMMARY, DATE_FORMAT(T5.MODI_DATE, \'%Y-%m-%d\') AS MODI_DATE, DATE_FORMAT(T5.PUBL_DATE, \'%Y-%m-%d\') AS PUBL_DATE FROM PROJECT_MASTER T1 INNER JOIN OSS_COMPONENTS T2 ON T1.PRJ_ID = T2.REFERENCE_ID  AND T2.REFERENCE_DIV = ( 	CASE WHEN T1.IDENTIFICATION_SUB_STATUS_ANDROID = \'Y\' THEN \'14\' ELSE \'13\' END )  AND T2.EXCLUDE_YN <> \'Y\' INNER JOIN OSS_MASTER T3 ON IFNULL(T2.REF_OSS_NAME, T2.OSS_NAME) = T3.OSS_NAME AND IFNULL(T2.OSS_VERSION, \'\') = IFNULL(T3.OSS_VERSION, \'\') AND T3.USE_YN = \'Y\' INNER JOIN OSS_DISCOVERED_SND_EMAIL T4 ON T3.OSS_ID = T4.OSS_ID AND T4.SND_YN != \'Y\' LEFT JOIN NVD_CVE_V3 T5 ON T4.CVE_ID = T5.CVE_ID WHERE T1.PRJ_ID = ?) RTN GROUP BY RTN.OSS_ID, RTN.CVE_ID ORDER BY RTN.OSS_NAME, RTN.CVSS_SCORE DESC, RTN.MODI_DATE DESC' WHERE CD_NO=104 AND CD_DTL_NO=207;

-- ADD UNIZUE INDEX OSS_COMMON TABLE
ALTER TABLE `OSS_COMMON` ADD UNIQUE INDEX `OSS_NAME_UNIQUE` (`OSS_NAME`);

INSERT INTO `T2_CODE_DTL` (`CD_NO`, `CD_DTL_NO`, `CD_DTL_NM`, `CD_SUB_NO`, `CD_DTL_EXP`, `CD_ORDER`, `USE_YN`) VALUES ('903', '012', 'crates.io/crates/', '', 'crates url', 12, 'Y');

-- Added ability to merge Notices in the Packaging Notice tab
ALTER TABLE `PROJECT_MASTER` ADD `NOTICE_APPEND_FILE_ID` INT(11) DEFAULT NULL;
ALTER TABLE `OSS_NOTICE` ADD `NOTICE_APPEND_TYPE` CHAR(1) DEFAULT 'E';
INSERT INTO `T2_CODE_DTL` (`CD_NO`, `CD_DTL_NO`, `CD_DTL_NM`, `CD_SUB_NO`, `CD_DTL_EXP`, `CD_ORDER`, `USE_YN`) VALUES ('120', '41', 'project notice append file', NULL, 'html,htm,txt', 15, 'Y');

-- Modify notice template path
UPDATE `T2_CODE_DTL` SET CD_DTL_EXP = 'notice/notice.html' WHERE CD_NO=219 AND CD_DTL_NO=5;
UPDATE `T2_CODE_DTL` SET CD_DTL_EXP = 'notice/notice.txt' WHERE CD_NO=219 AND CD_DTL_NO=6;
UPDATE `T2_CODE_DTL` SET CD_DTL_EXP = 'notice/supplement_notice.html' WHERE CD_NO=219 AND CD_DTL_NO=8;
UPDATE `T2_CODE_DTL` SET CD_DTL_EXP = 'notice/supplement_notice.txt' WHERE CD_NO=219 AND CD_DTL_NO=9;
UPDATE `T2_CODE_DTL` SET CD_DTL_EXP = 'notice/selfcheck_notice.html' WHERE CD_NO=219 AND CD_DTL_NO=10;
UPDATE `T2_CODE_DTL` SET CD_DTL_EXP = 'notice/selfcheck_notice.txt' WHERE CD_NO=219 AND CD_DTL_NO=11;

ALTER TABLE `T2_USERS` MODIFY `TOKEN` varchar(500);

-- Added primary key of nvd_data_v3 table
TRUNCATE TABLE `NVD_DATA_V3`;
ALTER TABLE `NVD_DATA_V3` DROP PRIMARY KEY;
ALTER TABLE `NVD_DATA_V3` ADD PRIMARY KEY (`CVE_ID`, `PRODUCT`, `VERSION`, `VENDOR`);

-- Add next_file_id sequence
CREATE SEQUENCE NEXT_FILE_ID START WITH 1 INCREMENT BY 1;

set @restart_sql:=concat('alter sequence NEXT_FILE_ID restart with ',(SELECT IFNULL(MAX(FILE_ID)+1, 1) FROM T2_FILE));
prepare restart_sequence from @restart_sql;
execute restart_sequence;
deallocate prepare restart_sequence;
