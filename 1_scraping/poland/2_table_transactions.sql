CREATE TABLE "public"."transactions" (
    download_timeout varchar(10) COLLATE "default",
    fund varchar(100) COLLATE "default",
    link varchar(30) COLLATE "default",
    loc text COLLATE "default",
    total_amount varchar(30) COLLATE "default",
    title varchar(255) COLLATE "default",
    beneficiary varchar(255) COLLATE "default",
    field varchar(30) COLLATE "default",
    depth varchar(3) COLLATE "default",
    program varchar(100) COLLATE "default",
    eu_amount varchar(30) COLLATE "default",
    action varchar(200) COLLATE "default",
    download_latency varchar(30) COLLATE "default",
    download_slot varchar(25) COLLATE "default"
)
WITH (OIDS=FALSE);