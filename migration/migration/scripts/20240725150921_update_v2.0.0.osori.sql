-- // update v2.0.0 improved osori db related functions
-- Migration SQL that makes the change goes here.

-- OSS_MASTER_COMMON CREATE TABLE
CREATE TABLE `OSS_COMMON` (
	`OSS_COMMON_ID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'OSS COMMON ID',
	`OSS_NAME` VARCHAR(200) NOT NULL COMMENT 'OSS 명' COLLATE 'utf8mb4_general_ci',
	`DOWNLOAD_LOCATION` VARCHAR(2000) NULL DEFAULT NULL COMMENT 'download URL or VCS(Version Control System)' COLLATE 'utf8mb4_general_ci',
	`HOMEPAGE` VARCHAR(2000) NULL DEFAULT NULL COMMENT 'oss 공식 홈페이지' COLLATE 'utf8mb4_general_ci',
	`SUMMARY_DESCRIPTION` MEDIUMTEXT NULL DEFAULT NULL COMMENT 'SUMMARY DESCRIPTION' COLLATE 'utf8mb4_general_ci',
	`USE_YN` CHAR(1) NULL DEFAULT 'Y' COMMENT '사용여부' COLLATE 'utf8mb4_general_ci',
	`DEACTIVATE_FLAG` CHAR(1) NULL DEFAULT 'N' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`OSS_COMMON_ID`) USING BTREE,
	INDEX `OSS_NAME` (`OSS_NAME`) USING BTREE,
	INDEX `OSS_COMMON_ID` (`OSS_COMMON_ID`) USING BTREE,
	INDEX `IN_CPE_MATCH_FLAG` (`IN_CPE_MATCH_FLAG`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;

-- OSS_COMMON TABLE DATA INSERT QUERY
INSERT INTO 
	OSS_COMMON (
		OSS_NAME
		, DOWNLOAD_LOCATION
		, HOMEPAGE
		, SUMMARY_DESCRIPTION
		, USE_YN	
		)		
		SELECT OSS_NAME
				, DOWNLOAD_LOCATION
				, HOMEPAGE
				, SUMMARY_DESCRIPTION
				, USE_YN
		FROM OSS_MASTER 
		WHERE USE_YN = 'Y' 
		GROUP BY OSS_NAME
		ORDER BY OSS_ID;

-- OSS_VERSION CREATE TABLE
CREATE TABLE `OSS_VERSION` (
	`OSS_ID` INT(11) NOT NULL COMMENT 'OSS ID',
	`OSS_COMMON_ID` INT(11) NOT NULL COMMENT 'OSS COMMON ID',
	`OSS_VERSION` VARCHAR(100) NULL DEFAULT NULL COMMENT 'OSS 버전' COLLATE 'utf8mb4_general_ci',
	`LICENSE_DIV` VARCHAR(6) NULL DEFAULT NULL COMMENT 'OSS 라이선스 구분(Single, Multi/Dual)' COLLATE 'utf8mb4_general_ci',
	`USE_YN` CHAR(1) NULL DEFAULT 'Y' COMMENT '사용여부' COLLATE 'utf8mb4_general_ci',
	`CREATOR` VARCHAR(50) NULL DEFAULT NULL COMMENT '등록자' COLLATE 'utf8mb4_general_ci',
	`CREATED_DATE` DATETIME NULL DEFAULT current_timestamp() COMMENT '등록일',
	`MODIFIER` VARCHAR(50) NULL DEFAULT NULL COMMENT '수정자' COLLATE 'utf8mb4_general_ci',
	`MODIFIED_DATE` DATETIME NULL DEFAULT current_timestamp() COMMENT '수정일',
	`VULN_CPE_NM` VARCHAR(128) NULL DEFAULT NULL COMMENT 'OSS CPE Name' COLLATE 'utf8mb4_general_ci',
	`CVSS_SCORE` VARCHAR(32) NULL DEFAULT NULL COMMENT 'OSS 취약 점수' COLLATE 'utf8mb4_general_ci',
	`CVE_ID` VARCHAR(16) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`VULN_YN` VARCHAR(1) NULL DEFAULT NULL COMMENT '취약점 검사 결과' COLLATE 'utf8mb4_general_ci',
	`VULN_RECHECK` VARCHAR(1) NULL DEFAULT 'N' COMMENT 'OSS 정보 변경시, 다음 BATCH대상으로 설정' COLLATE 'utf8mb4_general_ci',
	`VULN_DATE` DATETIME NULL DEFAULT NULL,
	`LICENSE_TYPE` VARCHAR(6) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`OBLIGATION_TYPE` VARCHAR(6) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`COPYRIGHT` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ATTRIBUTION` MEDIUMTEXT NULL DEFAULT NULL COMMENT 'ATTRIBUTION' COLLATE 'utf8mb4_general_ci',
	`RESTRICTION` VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`IN_CPE_MATCH_FLAG` CHAR(1) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`OSS_ID`) USING BTREE,
	INDEX `OSS_VERSION` (`OSS_VERSION`) USING BTREE,
	INDEX `CVSS_SCORE_VULN_YN` (`CVSS_SCORE`, `VULN_YN`) USING BTREE,
	INDEX `CVSS_SCORE` (`CVSS_SCORE`) USING BTREE,
	INDEX `OSS_ID_VULN_YN` (`OSS_ID`, `VULN_YN`) USING BTREE,
	INDEX `CVE_ID` (`CVE_ID`) USING BTREE,
	INDEX `OSS_COMMON_ID` (`OSS_COMMON_ID`) USING BTREE,
	KEY `IN_CPE_MATCH_FLAG` (`IN_CPE_MATCH_FLAG`)
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;

-- OSS_MASTER_VERSION TABLE DATA INSERT QUERY
INSERT INTO 
	OSS_VERSION (
		OSS_ID
		, OSS_COMMON_ID
		, OSS_VERSION
		, LICENSE_DIV
		, USE_YN
		, CREATOR
		, CREATED_DATE	
		, MODIFIER
		, MODIFIED_DATE
		, VULN_CPE_NM
		, CVSS_SCORE
		, CVE_ID
		, VULN_YN
		, VULN_RECHECK
		, VULN_DATE
		, LICENSE_TYPE
		, OBLIGATION_TYPE
		, DEACTIVATE_FLAG
		, COPYRIGHT
		, ATTRIBUTION
	)
	SELECT OM.OSS_ID
			, (SELECT OSS_COMMON_ID FROM OSS_COMMON WHERE OSS_NAME = OM.OSS_NAME)
			, OM.OSS_VERSION
			, OM.LICENSE_DIV
			, OM.USE_YN
			, OM.CREATOR
			, OM.CREATED_DATE	
			, OM.MODIFIER
			, OM.MODIFIED_DATE
			, OM.VULN_CPE_NM
			, OM.CVSS_SCORE
			, OM.CVE_ID
			, OM.VULN_YN
			, OM.VULN_RECHECK
			, OM.VULN_DATE
			, OM.LICENSE_TYPE
			, OM.OBLIGATION_TYPE
			, OM.DEACTIVATE_FLAG
			, OM.COPYRIGHT
			, OM.ATTRIBUTION
		FROM OSS_MASTER OM
		WHERE OM.USE_YN = 'Y'
		ORDER BY OM.OSS_ID;

-- OSS_MASTER TABLE RENAME
RENAME TABLE OSS_MASTER TO OSS_MASTER_E;

-- OSS_DOWNLOADLOCATION_COMMON CREATE TABLE
CREATE TABLE `OSS_DOWNLOADLOCATION_COMMON` (
	`OSS_COMMON_ID` INT(11) NOT NULL,
	`DOWNLOAD_LOCATION` VARCHAR(2000) NULL DEFAULT NULL COMMENT 'download URL or VCS(Version Control System)' COLLATE 'utf8mb4_general_ci',
	`PURL` VARCHAR(2000) NULL DEFAULT NULL COMMENT 'Package URL' COLLATE 'utf8mb4_general_ci',
	`OSS_DL_IDX` INT(11) NOT NULL,
	INDEX `OSS_COMMON_ID` (`OSS_COMMON_ID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;

INSERT INTO 
	OSS_DOWNLOADLOCATION_COMMON (
		OSS_COMMON_ID
		, DOWNLOAD_LOCATION
		, OSS_DL_IDX
	)
	SELECT OM.*, ROW_NUMBER() OVER (PARTITION BY OM.OSS_COMMON_ID) AS SEQ
	FROM
	(
		SELECT OV.OSS_COMMON_ID
		, OD.DOWNLOAD_LOCATION
		FROM OSS_DOWNLOADLOCATION OD
		LEFT JOIN OSS_VERSION OV
		ON OD.OSS_ID = OV.OSS_ID
		WHERE OV.OSS_COMMON_ID IS NOT NULL
		GROUP BY OV.OSS_COMMON_ID, OD.DOWNLOAD_LOCATION
	) OM;

-- OSS_DOWNLOADLOCATION TABLE RENAME
RENAME TABLE OSS_DOWNLOADLOCATION TO OSS_DOWNLOADLOCATION_E;

-- OSS_DOWNLOADLOCATION_COMMON TABLE RENAME
RENAME TABLE OSS_DOWNLOADLOCATION_COMMON TO OSS_DOWNLOADLOCATION;

-- OSS_INCLUDE_CPE CREATE TABLE
CREATE TABLE `OSS_INCLUDE_CPE` (
	`OSS_COMMON_ID` INT(11) NOT NULL,
	`CPE23URI` VARCHAR(256) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	INDEX `OSS_COMMON_ID` (`OSS_COMMON_ID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=INNODB;

-- OSS_EXCLUDE_CPE CREATE TABLE
CREATE TABLE `OSS_EXCLUDE_CPE` (
	`OSS_COMMON_ID` INT(11) NOT NULL,
	`CPE23URI` VARCHAR(256) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	INDEX `OSS_COMMON_ID` (`OSS_COMMON_ID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=INNODB;

-- OSS_VERSION_ALIAS CREATE TABLE
CREATE TABLE `OSS_VERSION_ALIAS` (
	`OSS_ID` INT(11) NOT NULL,
	`OSS_VERSION_ALIAS` VARCHAR(100) NOT NULL COMMENT 'OSS Version Alias' COLLATE 'utf8mb4_general_ci',
	INDEX `OSS_ID` (`OSS_ID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;

-- OSS_NICKNAME EDIT TABLE
CREATE TABLE `OSS_NICKNAME_COMMON` (
	`OSS_COMMON_ID` INT(11) NOT NULL COMMENT 'OSS MASTER ID',
	`OSS_NICKNAME` VARCHAR(200) NOT NULL COMMENT 'OSS NICKNAME' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`OSS_COMMON_ID`, `OSS_NICKNAME`) USING BTREE,
	INDEX `OSS_COMMON_ID` (`OSS_COMMON_ID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;

INSERT INTO 
	OSS_NICKNAME_COMMON (
		OSS_COMMON_ID
		, OSS_NICKNAME
	)
	SELECT OC.OSS_COMMON_ID, NICK.OSS_NICKNAME
	FROM OSS_COMMON OC
	INNER JOIN OSS_NICKNAME NICK
	ON OC.OSS_NAME = NICK.OSS_NAME;

-- OSS_NICKNAME TABLE RENAME
RENAME TABLE OSS_NICKNAME TO OSS_NICKNAME_E;

-- OSS_NICKNAME_COMMON TABLE RENAME
RENAME TABLE OSS_NICKNAME_COMMON TO OSS_NICKNAME;

-- LICENSE_NICKNAME EDIT TABLE
CREATE TABLE `LICENSE_NICKNAME_NEW` (
	`LICENSE_ID` INT(11) NOT NULL COMMENT '라이선스 ID',
	`LICENSE_NICKNAME` VARCHAR(200) NOT NULL COMMENT '라이선스 닉네임' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`LICENSE_ID`, `LICENSE_NICKNAME`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=INNODB;

INSERT INTO 
	LICENSE_NICKNAME_NEW (
		LICENSE_ID
		, LICENSE_NICKNAME
	)
	SELECT LM.LICENSE_ID, NICK.LICENSE_NICKNAME
	FROM LICENSE_MASTER LM
	INNER JOIN LICENSE_NICKNAME NICK
	ON LM.LICENSE_NAME = NICK.LICENSE_NAME
	GROUP BY LM.LICENSE_ID, NICK.LICENSE_NICKNAME;

-- LICENSE_NICKNAME TABLE RENAME
RENAME TABLE LICENSE_NICKNAME TO LICENSE_NICKNAME_E;

-- LICENSE_NICKNAME_NEW TABLE RENAME
RENAME TABLE LICENSE_NICKNAME_NEW TO LICENSE_NICKNAME;

-- ADD COLUMN LICENSE_MASTER TABLE
ALTER TABLE `LICENSE_MASTER` ADD `DISCLOSING_SRC` VARCHAR(25) NULL DEFAULT NULL;

-- ADD DATA T2_CODE TABLE
INSERT INTO `T2_CODE` (`CD_NO`, `CD_NM`, `CD_EXP`, `SYS_CD_YN`) VALUES ('230', 'Source Code Disclosure Scope', 'Source Code Disclosure Scope', 'N');
INSERT INTO `T2_CODE` (`CD_NO`, `CD_NM`, `CD_EXP`, `SYS_CD_YN`) VALUES ('913', 'check Package Url', 'download location 으로 purl 을 생성하기 위한 정보관리', 'N');

-- ADD DATA T2_CODE_DTL TABLE
INSERT INTO `T2_CODE_DTL` (`CD_NO`, `CD_DTL_NO`, `CD_DTL_NM`, `CD_SUB_NO`, `CD_DTL_EXP`, `CD_ORDER`, `USE_YN`) VALUES
	('214', '40', 'current_version', '', '', 11, 'Y'),
	('214', '42', 'all_version', '', '', 12, 'Y'),
	('230', '1', 'NONE', '', '', 1, 'Y'),
	('230', '2', 'ORIGINAL', '', '', 2, 'Y'),
	('230', '3', 'FILE', '', '', 3, 'Y'),
	('230', '4', 'MODULE', '', '', 4, 'Y'),
	('230', '5', 'LIBRARY', '', '', 5, 'Y'),
	('230', '6', 'DERIVATIVE WORK', '', '', 6, 'Y'),
	('230', '7', 'EXECUTABLE', '', '', 7, 'Y'),
	('230', '8', 'DATA', '', '', 8, 'Y'),
	('230', '9', 'SOFTWARE USING THIS', '', '', 9, 'Y'),
	('230', '10', 'UNSPECIFIED', '', '', 10, 'Y'),
	('913', '001', 'github.com', '', 'github', 1, 'Y'),
	('913', '002', 'www.npmjs.com/package/', '', 'npm', 2, 'Y'),
	('913', '003', 'registry.npmjs.org', '', 'npm', 3, 'Y'),
	('913', '004', 'pypi.python.org/project/', '', 'pypi', 4, 'Y'),
	('913', '005', 'pypi.org/project/', '', 'pypi', 5, 'Y'),
	('913', '006', 'mvnrepository.com/artifact/', '', 'maven', 6, 'Y'),
	('913', '007', 'repo.maven.apache.org/maven2/', '', 'maven', 7, 'Y'),
	('913', '008', 'cocoapods.org/pods/', '', 'cocoapod', 8, 'Y'),
	('913', '009', 'rubygems.org/gems/', '', 'gem', 9, 'Y'),
	('913', '010', 'pkg.go.dev', '', 'go', 10, 'Y'),
	('913', '011', 'android.googlesource.com/platform/', '', 'android', 11, 'Y'),
	('913', '012', 'pub.dev/packages/', '', 'pub', 12, 'Y');

-- Code management
UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT T1.CREATOR, T1.CREATED_DATE, T1.OSS_ID, T1.OSS_NAME, T1.OSS_VERSION, IFNULL(( SELECT GROUP_CONCAT(D.DOWNLOAD_LOCATION ORDER BY D.OSS_DL_IDX ASC) FROM OSS_DOWNLOADLOCATION D WHERE D.OSS_COMMON_ID = T1.OSS_COMMON_ID), T1.DOWNLOAD_LOCATION) AS DOWNLOAD_LOCATION, T1.HOMEPAGE, T1.SUMMARY_DESCRIPTION, T1.ATTRIBUTION, T1.COPYRIGHT, T1.LICENSE_TYPE AS OSS_LICENSE_TYPE, T1.OBLIGATION_TYPE AS OSS_OBLIGATION_TYPE, GROUP_CONCAT(T4.OSS_NICKNAME SEPARATOR ''\n'') AS OSS_NICKNAME, T2.LICENSE_ID, T2.OSS_LICENSE_IDX, T2.OSS_LICENSE_COMB, T2.OSS_COPYRIGHT, T2.OSS_LICENSE_TEXT, IF(IFNULL(T3.SHORT_IDENTIFIER, '') = '', T3.LICENSE_NAME, T3.SHORT_IDENTIFIER) AS LICENSE_NAME, T3.LICENSE_TYPE, SUB1.OSS_TYPE, IFNULL(( SELECT GROUP_CONCAT(IF(LM.SHORT_IDENTIFIER = '' OR LM.SHORT_IDENTIFIER IS NULL, LM.LICENSE_NAME, LM.SHORT_IDENTIFIER) ORDER BY OSS_LICENSE_IDX ASC) FROM OSS_LICENSE_DETECTED ODT INNER JOIN LICENSE_MASTER LM ON ODT.LICENSE_ID = LM.LICENSE_ID WHERE ODT.OSS_ID = T1.OSS_ID), '') AS DETECTED_LICENSE FROM OSS_MASTER T1 INNER JOIN OSS_LICENSE_DECLARED T2 ON T1.OSS_ID = T2.OSS_ID INNER JOIN LICENSE_MASTER T3 ON T2.LICENSE_ID = T3.LICENSE_ID LEFT OUTER JOIN OSS_NICKNAME T4 ON T1.OSS_COMMON_ID = T4.OSS_COMMON_ID INNER JOIN ( SELECT OSS_ID, CONCAT(IF(MULTI_LICENSE_FLAG = ''N'', ''0'', ''1''), IF(DUAL_LICENSE_FLAG = ''N'', ''0'', ''1''), IF(VERSION_DIFF_FLAG = ''N'', ''0'', ''1'')) AS OSS_TYPE FROM OSS_MASTER_LICENSE_FLAG) SUB1 ON T1.OSS_ID = SUB1.OSS_ID WHERE T1.OSS_ID = ? GROUP BY OSS_ID, OSS_LICENSE_IDX' WHERE CD_NO=104 AND CD_DTL_NO=100;
UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT T1.LICENSE_ID, T1.LICENSE_NAME, T1.LICENSE_TYPE, T1.OBLIGATION_DISCLOSING_SRC_YN, T1.OBLIGATION_NOTIFICATION_YN, T1.OBLIGATION_NEEDS_CHECK_YN, T1.SHORT_IDENTIFIER, GROUP_CONCAT(T2.WEBPAGE ORDER BY SORT_ORDER ASC) AS WEBPAGE, T1.DESCRIPTION, T1.LICENSE_TEXT, T1.ATTRIBUTION, T1.USE_YN, T1.CREATOR, T1.CREATED_DATE, T1.MODIFIER, T1.MODIFIED_DATE, T1.REQ_LICENSE_TEXT_YN, T1.RESTRICTION, T1.LICENSE_NICKNAME, T1.DISCLOSING_SRC  FROM ( SELECT T1.*, GROUP_CONCAT(T2.LICENSE_NICKNAME) AS LICENSE_NICKNAME FROM LICENSE_MASTER T1 LEFT OUTER JOIN LICENSE_NICKNAME T2 ON T1.LICENSE_ID = T2.LICENSE_ID WHERE T1.LICENSE_ID = ?) T1 LEFT JOIN LICENSE_WEBPAGE T2 ON T1.LICENSE_ID = T2.LICENSE_ID' WHERE CD_NO=104 AND CD_DTL_NO=101;
UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT RTN.OSS_ID, RTN.OSS_NAME, RTN.OSS_VERSION, RTN.CVSS_SCORE, RTN.CVE_ID, RTN.VULN_SUMMARY, RTN.MODI_DATE, RTN.PUBL_DATE FROM (SELECT T2.OSS_ID, T2.OSS_NAME, T2.OSS_VERSION, T4.CVSS_SCORE, T4.CVE_ID, T5.VULN_SUMMARY, DATE_FORMAT(T5.MODI_DATE, ''%Y-%m-%d'') AS MODI_DATE, DATE_FORMAT(T5.PUBL_DATE, ''%Y-%m-%d'') AS PUBL_DATE, CAST(HIS.CVSS_SCORE AS DECIMAL(10, 1)) AS HIS_CVSS_SCORE, CAST(HIS.CVSS_SCORE_TO AS DECIMAL(10, 1)) AS HIS_CVSS_SCORE_TO FROM PROJECT_MASTER T1 INNER JOIN OSS_COMPONENTS T2 ON T1.PRJ_ID = T2.REFERENCE_ID AND T2.REFERENCE_DIV = ''50'' AND T2.EXCLUDE_YN <> ''Y'' LEFT JOIN (SELECT OC.OSS_NAME, NICK.OSS_NICKNAME FROM OSS_NICKNAME NICK INNER JOIN OSS_COMMON OC ON NICK.OSS_COMMON_ID = OC.OSS_COMMON_ID) T3 ON T2.OSS_NAME = T3.OSS_NICKNAME INNER JOIN OSS_MASTER T4 ON (T2.OSS_NAME = T4.OSS_NAME OR T3.OSS_NAME = T4.OSS_NAME) AND T2.OSS_VERSION = T4.OSS_VERSION AND T4.VULN_YN = ''Y'' AND T4.USE_YN = ''Y'' AND T4.VULN_DATE > ADDDATE(SYSDATE(), INTERVAL - 2 DAY) LEFT JOIN NVD_CVE_V3 T5 ON T4.CVE_ID = T5.CVE_ID INNER JOIN NVD_OSS_HIS HIS ON IFNULL(T4.OSS_NAME, T2.OSS_NAME) = HIS.OSS_NAME AND T2.OSS_VERSION = HIS.OSS_VERSION AND HIS.REG_DT > ADDDATE(SYSDATE(), INTERVAL - 1 DAY) WHERE T1.PRJ_ID = ?) RTN WHERE RTN.HIS_CVSS_SCORE_TO < RTN.HIS_CVSS_SCORE AND HIS_CVSS_SCORE >= ? AND HIS_CVSS_SCORE_TO < ? GROUP BY RTN.OSS_ID ORDER BY RTN.OSS_NAME' WHERE CD_NO=104 AND CD_DTL_NO=210;
UPDATE T2_CODE_DTL SET CD_DTL_EXP='SELECT RTN.OSS_ID, RTN.OSS_NAME, RTN.OSS_VERSION, IFNULL(RTN.CVSS_SCORE, '') AS CVSS_SCORE, IFNULL(RTN.CVE_ID, '') AS CVE_ID, IFNULL(RTN.VULN_SUMMARY, '') AS VULN_SUMMARY, IFNULL(RTN.MODI_DATE, '') AS MODI_DATE, IFNULL(RTN.PUBL_DATE, '') AS PUBL_DATE FROM ( SELECT T2.OSS_ID, T2.OSS_NAME, T2.OSS_VERSION, T4.CVSS_SCORE, T4.CVE_ID, T5.VULN_SUMMARY, DATE_FORMAT(T5.MODI_DATE, ''%Y-%m-%d'') AS MODI_DATE, DATE_FORMAT(T5.PUBL_DATE, ''%Y-%m-%d'') AS PUBL_DATE, CAST(HIS.CVSS_SCORE AS DECIMAL(10, 1)) AS HIS_CVSS_SCORE, CAST(HIS.CVSS_SCORE_TO AS DECIMAL(10, 1)) AS HIS_CVSS_SCORE_TO FROM PROJECT_MASTER T1 INNER JOIN OSS_COMPONENTS T2 ON T1.PRJ_ID = T2.REFERENCE_ID AND T2.REFERENCE_DIV = ''50'' AND T2.EXCLUDE_YN <> ''Y'' LEFT JOIN ( SELECT OC.OSS_NAME, NICK.OSS_NICKNAME FROM OSS_NICKNAME NICK INNER JOIN OSS_COMMON OC ON NICK.OSS_COMMON_ID = OC.OSS_COMMON_ID) T3 ON T2.OSS_NAME = T3.OSS_NICKNAME INNER JOIN OSS_MASTER T4 ON (T2.OSS_NAME = T4.OSS_NAME OR T3.OSS_NAME = T4.OSS_NAME) AND T2.OSS_VERSION = T4.OSS_VERSION AND T4.VULN_YN = ''N'' AND T4.USE_YN = ''Y'' AND T4.VULN_DATE IS NULL LEFT JOIN NVD_CVE_V3 T5 ON T4.CVE_ID = T5.CVE_ID INNER JOIN NVD_OSS_HIS HIS ON IFNULL(T4.OSS_NAME, T2.OSS_NAME) = HIS.OSS_NAME AND T2.OSS_VERSION = HIS.OSS_VERSION AND HIS.REG_DT > ADDDATE(SYSDATE(), INTERVAL - 3 DAY) WHERE T1.PRJ_ID = ?) RTN WHERE RTN.HIS_CVSS_SCORE_TO < RTN.HIS_CVSS_SCORE AND HIS_CVSS_SCORE >= ? AND HIS_CVSS_SCORE_TO < ? GROUP BY RTN.OSS_ID ORDER BY RTN.OSS_NAME' WHERE CD_NO=104 AND CD_DTL_NO=214;

-- ADD UNIZUE INDEX OSS_VERSION TABLE
ALTER TABLE `OSS_VERSION` ADD UNIQUE INDEX `OSS_COMMON_ID_OSS_VERSION` (`OSS_COMMON_ID`, `OSS_VERSION`);