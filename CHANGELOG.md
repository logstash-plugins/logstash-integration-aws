## 3.0.5
  - [#22](https://github.com/logstash-plugins/logstash-codec-cloudtrail/pull/22)Handle 'sourceIpAddress' fields with non-ip address content by moving them to 'sourceHost' field

## 3.0.4
  - Don't crash when data doesn't contain some particular elements

## 3.0.3
  - Fix some documentation issues

# 3.0.1
  - fixed mapping template for requestParameters.disableApiTermination field

## 3.0.0
  - Update to support Logstash 2.4 & 5.0 APIs
  
## 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
  
## 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
  
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

