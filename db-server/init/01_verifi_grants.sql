-- 첫 기동 때 한 번만 실행된다 (SYS 권한). 앱 계정 이름이 verifi가 아니면 아래를 바꾸세요.
ALTER SESSION SET CONTAINER = FREEPDB1;

GRANT UNLIMITED TABLESPACE TO verifi;
-- 시스템 화면에서 DB 버전을 보여주기 위함 (없어도 앱은 동작)
GRANT SELECT ON SYS.V_$VERSION TO verifi;

-- 시연 중 연결이 끊기지 않도록 비밀번호 만료 해제
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
