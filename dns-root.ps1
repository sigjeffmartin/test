# define function to perform paramaterized SQL queries
# this will make JD happy by avoiding SQL injection attacks on a purely internal script 
# that only has read only creds in it
function exec-query( $sql,$parameters=@{},$conn,$timeout=600,[switch]$help){
 if ($help){
 $msg = @"
Execute a sql statement.  Parameters are allowed.
Input parameters should be a dictionary of parameter names and values.
Return value will usually be a list of datarows.
"@
 Write-Host $msg
 return
 }
 $cmd=new-object system.Data.SqlClient.SqlCommand($sql,$conn)
 $cmd.CommandTimeout=$timeout
 foreach($p in $parameters.Keys){
 [Void] $cmd.Parameters.AddWithValue("@$p",$parameters[$p])
 }
 $ds=New-Object system.Data.DataSet
 $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
 $da.fill($ds) | Out-Null

 return $ds
}

function is-null($value){
  return  [System.DBNull]::Value.Equals($value)
}

# open SQL connection



$query= @"
use skynet;
DECLARE @DESTPORT as nchar(5)
DECLARE @IPADDY AS varchar(19)
DECLARE @TESTDATE AS date
DECLARE @ACTION AS varchar(10)

SET @TESTDATE = DATEADD("d",-2,GetDate())
SET @DESTPORT = '53'
SET @ACTION = '!=drop'

select sourceIP,destIP from dbo.vw_NSM_SummarizedLogs
WHERE
(firewall = '10.11.253.110' OR firewall = '10.11.253.111' OR firewall = '10.11.253.112') AND 
(destIP IN ('198.41.0.4','192.228.79.201','192.33.4.12','128.8.10.90','192.203.230.10','192.5.5.241','192.112.36.4','128.63.2.53','192.36.148.17','192.58.128.30','193.0.14.129','198.32.64.12','202.12.27.33') )
AND destPort = @DESTPORT
AND summarizedDateStart > @TESTDATE
UNION
select sourceIP,destIP from dbo.vw_CP_SummarizedLogs
WHERE
(firewall = '10.11.253.110' OR firewall = '10.11.253.111' OR firewall = '10.11.253.112') AND
(destIP IN ('198.41.0.4','192.228.79.201','192.33.4.12','128.8.10.90','192.203.230.10','192.5.5.241','192.112.36.4','128.63.2.53','192.36.148.17','192.58.128.30','193.0.14.129','198.32.64.12','202.12.27.33') )
AND destPort = @DESTPORT
AND summarizedDateStart > @TESTDATE
order by sourceIP desc
"@

$result = exec-query $query -conn $connection
foreach ($LINE in $result.Tables[0].Rows) 
	{
	write-host $LINE.sourceIP,$LINE.destIP
	}

$connection.Close()








