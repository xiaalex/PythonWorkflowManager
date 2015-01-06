Python Workflow Manager (Under construction!)
=====================

I use my free time to do this and I will try to get done as soon as I can. The following is the framework design. 

The Python Workflow Manager (PWM) is a framework designed to support ETL in data warehouse environment. The framework is implemented in Python and most user program that is excutable in batch mode on command line can be run in this framework. The only requirement for the user program is that they needs to accept options and other arguments. 

The workflow manager is consisted of a lot of scripts and each script accomplishes certain ETL task. There are three components in this framework, worflow manager, scheduler and logger.

Workflow

The followings are some key concepts used in the framework.  

Job
    A job is a script that accomplishes certain ETL task. The job may accept some options and arguments. 

Job Group
    A group is consisted of one or more jobs. Several groups of jobs are running in parallel. A group is launched as a process and groups are independent from each other. For example, we may run main ETL job and third party ftp report job in different group and they can be run in parallel.

    The jobs in a group run in seqence of "order_id". For example, we load dimensions first and then load fact tables
as shown below.
    job_id  job_name    order_id
		1       load_dim    10
		2       load_fact   20

Bucket
    A bucket is the unit of a job. For example, a bucket for daily job is a day and for hourly job is a hour.

    The bucket use format to indicate daily, hourly, or special bucket. For example,
		    day:	YYYYMMDD
		    hour:	YYYYMMDDHH

	  If there are more than one bucket to run, normally the launcher will select the oldest bucket to run. If the "is_batch" column is "Y", then several available buckets may be run in a job. For example, for a hourly job, we may have run hour1 hour3 hour4 hour7 in a job.

    Suppose we run a daily job, there are three days needs to be run, then the launcher will select oldest bucket 
(the day before yesterday). If "is_exact_match" column is "Y", then the launcher will select only today and previous days will never be run. 
        day before yesterday	INIT
        yesterday             INIT
        today                 INIT

How to get bucket

    There are two ways to get bucket. The first way is to get from status table. In this case, the bucket column is null. The job bucket is already pre-populated in job_status table.

    The second way to get from bucket column via store procedure or script. 

    There are many different appraoches to get the bucket.
	
    a) The bucket is formated as YYYYMMDD or YYYYMMDDHH to indicate daily or hourly job. 

    b) The bucket is defined as key. For example, to run a job for previous day, we define a key named "PreviousDay". In "job_bucket" table, we can define a procedure or a script to return the bucket value.
        bucket              db_proc             script
        PreviousDay         get_prev_day        null
        FirstDayofMonth     null                get_first_day_of_month
        FirstDayOfWeek      null                get_first_day_of_week

    c) The bucket is defined as range. For example, we need run a report with start date and end date. The bucket procedure will return a string with two values as " start end " and pass this string as parameter to the job. It is upto the script to retrive the start and end values.  
        run_range_load.sh "start" "end"
	
    d) The bucket can have format. If your script can handle mixed option and arguments, then you can format the bucket before returning. 
        bucket		  db_proc	script				    format
        MyParameter	null	  get_parameter.sh	-c $1 -t $2 -f $3

Context
    
    A job can have additional context information passed to it in the form of options. We can pass context as string, file or script (See script revolver). 

Dependency

	  A job can have dependency. The dependency requirement must be met before the job can be run. This forms the parent-child relation. The dependency can be defined with job id or script. 

    By default, to check the parent job, the same bucket will be used. For example, a daily summary job depends on the daily data processing job. 
		child_id bucket --> parent_id bucket
		2        yyyymmdd	1         yyyymmdd

    In above example, the job 2 depends on job 1 to continue.
		job_id	bucket		status		timestamp
		1		20141215	COMPLETE	2014-12-19 17:29:52.253
		2		20141215	INIT		2014-12-19 17:30:39.370

	We may have some complex dependency like range dependency. For example, we need to run a summary job for every 6 hour, or we need to run daily job 
    when previous 24 hours are done. 
			job_id	bucket		status		timestamp
			1		2014121500	COMPLETE	2014-12-19 17:29:52.253
					........
			1		2014121523	COMPLETE	2014-12-19 17:29:52.253

    In above case, all previous 24 hours job must be done before we can run daily job. we can use script to check the dependency.
			job_id	dep_job_id	dep_script
			3		1			is_24h_done.sh		# use prev day yyyymmdd to check all 24 hours complete,
                                                    # script must handle from yyyymmdd to yyyymmddhh conversion

	Sometimes, we need to check system dependency. For example, we nned to check if hadoop/hive/hbase is up and we do not have dependency id in this case.

		job_id	dep_job_id	dep_script
		3		null		is_hadoop_up.sh		# system dependency

Loop 
	
    If there is a record in "job_loop", the job will be looped against all values returned from "job_loop". The values format is "vales1|values2|values3".  
	The launcher will split the values string into array and run job in loop.

OnInit, OnSuccess and OnError

    There are three events in which can run your script. For example, you may send success email when a job is done.

Environment variable

    The environment variable provides some extra information to the job.

    PIPEJOBID       the job id
    PIPEJOBSCRIPT   the script name
    PIPEINOUT       the output of a script will be used to populated this variable and is used as input for next script
    PIPEERROR       the error output of a script
    PIPEFILE        a filename if input is too big 

