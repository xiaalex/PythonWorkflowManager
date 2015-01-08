use pwm;

create table pwm.job_group ( 
	group_id                int(11) not null,
	order_id                int(11) not null,
	group_desc              varchar(500) null,
	primary key (group_id)
);

create table pwm.job (
    job_id                  int(11) not null,
    group_id                int(11) not null,
    order_id                int(11) not null,
    job_name                varchar(100) null,
    enabled                 varchar(1) not null,
    script                  varchar(200) not null,
    bucket                  varchar(200) null,
    context_id              int(11) null,
    is_batch                varchar(1) not null,
    is_exact_match          varchar(1) not null,
    job_desc                varchar(500) null,
	primary key (job_id)
);

create table pwm.job_bucket ( 
	bucket      	        varchar(200) not null,
	db_proc     	        varchar(200) null,
	script      	        varchar(200) null,
	param_format	        varchar(200) null,
	primary key (bucket)
);

create table pwm.job_context (
    context_id              int(11) not null,
    context_value           varchar(500) null,
    context_file            varchar(200) null,
    context_script          varchar(200) null,
	primary key (context_id)
);

create table pwm.job_loop ( 
	job_id                  int(11) not null,
	loop_var                varchar(500) null,
	loop_script             varchar(200) null,
	primary key (job_id)
);

create table pwm.job_branch ( 
	branch_id               int(11) not null,
	merge_id                int(11) not null,
	job_in_branch           int(11) not null
);

create table pwm.job_dependency ( 
	job_id                  int(11) not null,
	dep_job_id              int(11) null,
	dep_script              varchar(200) null,
	primary key (job_id)
);

create table pwm.job_net_parameter  ( 
	job_id                  int(11) not null,
	parameter_id            int(11) not null,
	parameter_type_id       int(11) not null,
	server                  varchar(200) null,
	user_name               varchar(200) null,
	pass_word               varchar(200) null,
	host_key                varchar(200) null,
	cert_file               varchar(200) null,
	remote_dir              varchar(200) null,
	remote_filename         varchar(200) null,
	local_dir               varchar(200) null,
	local_filename          varchar(200) null,
	primary key (job_id)
);

create table pwm.job_net_parameter_type ( 
	parameter_type_id       int(11) not null,
	parameter_type_name     varchar(50) not null,
	primary key (parameter_type_id)
);

create table pwm.job_status ( 
	job_id                  int(11) not null,
	bucket                  varchar(200) not null,
	status                  varchar(50) not null,
	update_date             datetime not null,
	primary key (job_id, bucket)
);

create table pwm.job_schedule ( 
	job_id                  int(11) not null,
	minute                  varchar(200) not null,
	hour                    varchar(200) not null,
	day_of_month            varchar(200) not null,
	month                   varchar(200) not null,
	day_of_week             varchar(200) not null,
	primary key(job_id)
);

