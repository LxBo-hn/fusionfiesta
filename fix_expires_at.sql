-- Fix Laravel Sanctum expires_at column
-- Chạy SQL này trong MySQL database

-- Cách 1: Thêm cột expires_at vào bảng personal_access_tokens
ALTER TABLE personal_access_tokens 
ADD COLUMN expires_at TIMESTAMP NULL AFTER abilities;

-- Cách 2: Nếu muốn reset toàn bộ bảng (xóa data cũ)
-- DROP TABLE IF EXISTS personal_access_tokens;
-- CREATE TABLE personal_access_tokens (
--     id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
--     tokenable_type varchar(255) NOT NULL,
--     tokenable_id bigint(20) unsigned NOT NULL,
--     name varchar(255) NOT NULL,
--     token varchar(64) NOT NULL,
--     abilities text,
--     expires_at timestamp NULL DEFAULT NULL,
--     last_used_at timestamp NULL DEFAULT NULL,
--     created_at timestamp NULL DEFAULT NULL,
--     updated_at timestamp NULL DEFAULT NULL,
--     PRIMARY KEY (id),
--     UNIQUE KEY personal_access_tokens_token_unique (token),
--     KEY personal_access_tokens_tokenable_type_tokenable_id_index (tokenable_type,tokenable_id)
-- );
