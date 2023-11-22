-module(cloud).

-include_lib("eunit/include/eunit.hrl").
-export([cloud_env/0, open_db/1]).

access_key() ->
  os:getenv("MINIO_ACCESS_KEY", "admin").

secret_key()->
  os:getenv("MINIO_SECRET_KEY", "password").

endpoint() ->
  os:getenv("ENDPOINT", "localhost:4566").

%% norsk-framestore / norsk-bucket / norsk-prefix
%% first bit currently hardwired in env.cc

src_name() -> "norsk-bucket".
src_prefix() -> "norsk-prefix".
src_region() -> "eu-west-1".
dest_name() -> "norsk-bucket".
dest_prefix() -> "norsk-prefix".
dest_region() -> "eu-west-1".

cloud_env() ->
  Credentials = [{access_key_id, access_key()},
                 {secret_key, secret_key()}],
  AwsOptions =  [{endpoint_override, endpoint()}, {scheme, "http"}],
  %%EnvOptions = [{credentials, Credentials}, {aws_options, AwsOptions}],
  EnvOptions = [{aws_options, AwsOptions}],
  {ok, CloudEnv} = rocksdb:new_cloud_env(src_name(), src_prefix(), src_region(), dest_name(), dest_prefix(), dest_region(), EnvOptions),
  ok = rocksdb:cloud_env_empty_bucket(CloudEnv, "norsk-framestore/", "norsk-bucket"),
  rocksdb:new_cloud_env(src_name(), src_prefix(), src_region(), dest_name(), dest_prefix(), dest_region(), EnvOptions).

open_db(CloudEnv) ->
  DbOptions =  [{create_if_missing, true}, {env, CloudEnv}],
  rocksdb:open_cloud_db("cloud_db", DbOptions, "/tmp/test", 128 bsl 20).


close_db(Db) ->
  ok = rocksdb:flush(Db, []),
  rocksdb:close(Db).

destroy_db() ->
  rocksdb:destroy("cloud_db", []).

basic_test_() ->
  [ {timeout, 60000, [
      fun basic_testx/0
  ]}
    
  ].

time(Msg, Fun) ->
  {Time, Res} = timer:tc(Fun),
  io:format(user, "~s: ~p~n", [Msg, Time]),
  Res.

basic_testx() ->
  %%timer:sleep(15000),
  os:cmd("rm -rf cloud_db"),
  Value = binary:copy(<<0>>, 100000),
  try
    {ok, CloudEnv} = cloud_env(),
    {ok, Db} = time("open", fun() -> open_db(CloudEnv) end),

    ok = rocksdb:put(Db, <<"key">>, <<"value">>, []),
    {ok, <<"value">>} = rocksdb:get(Db, <<"key">>, []),

    %% time("put 1000", fun() -> 
    %%         lists:foreach(fun(N) ->
    %%           ok = rocksdb:put(Db, integer_to_binary(N), Value, [])
    %%         end, lists:seq(1, 1000))
    %%       end),
          
    ok = time("close", fun() -> close_db(Db) end),

    {ok, Db1} = open_db(CloudEnv),
    {ok, <<"value">>} = rocksdb:get(Db1, <<"key">>, []),
    
    %%  time("get1000", fun() -> 
    %%         lists:foreach(fun(N) ->
    %%           {ok, _} = rocksdb:get(Db1, integer_to_binary(N), [])
    %%         end, lists:seq(1, 1000))
    %%       end),
    close_db(Db1)
  after
    destroy_db()
  end.


