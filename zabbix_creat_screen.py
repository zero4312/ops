#!/bin/env python
import json
import urllib2
import argparse
import re

re_digits = re.compile(r'(\d+)')


def emb_numbers(s):
    pieces = re_digits.split(s)
    pieces[1::2] = map(int, pieces[1::2])
    return pieces


def sort_strings_with_emb_numbers2(alist):
    return sorted(alist, key=emb_numbers)


def requestjson(url, values):
    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    res = urllib2.urlopen(req, data)
    output = json.loads(res.read())

    return output


def authenticate(url, username, password):
    values = {'jsonrpc': '2.0',
              'method': 'user.login',
              'params': {
                  'user': username,
                  'password': password
              },
              'id': '0'
              }
    output = requestjson(url, values)

    return output['result']


def gethosts(groupname, url, auth):
    host_list = {}
    values = {'jsonrpc': '2.0',
              'method': 'hostgroup.get',
              'params': {
                  'output': 'extend',
                  'filter': {'name': groupname},
                  'selectHosts': ['host']
              },
              'auth': auth,
              'id': '2'
              }
    output = requestjson(url, values)
    for host in output['result'][0]['hosts']:
        host_list[host['host']] = (host['hostid'])

    # return host_list
    hosts_sort = []
    for host in sort_strings_with_emb_numbers2(host_list.keys()):
        hosts_sort.append(host_list[host])
    return hosts_sort


def getgraphs(host_list, name_list, url, auth, columns, graphtype=0, dynamic=0):
    if (graphtype == 0):
        selecttype = ['graphid']
        select = 'selectGraphs'
    if (graphtype == 1):
        selecttype = ['itemid', 'value_type']
        select = 'selectItems'

    graphs = []
    for host in host_list:
        values = ({'jsonrpc': '2.0',
                   'method': 'graph.get',
                   'params': {
                       select: [selecttype, 'name'],
                       'output': ['graphid', 'name'],
                       'hostids': host,
                       'filter': {'name': name_list},
                       'sortfield': 'name'
                   },
                   'auth': auth,
                   'id': '3'
                   })
        output = requestjson(url, values)
        bb = sorted(output['result'])
        if (graphtype == 0):
            for i in bb:
                graphs.append(i['graphid'])
        if (graphtype == 1):
            for i in bb:
                if int(i['value_type']) in (0, 3):
                    graphs.append(i['itemid'])

    graph_list = []
    x = 0
    y = 0
    for graph in graphs:
        graph_list.append({
            'resourcetype': graphtype,
            'resourceid': graph,
            'width': '230',
            'height': '100',
            'x': str(x),
            'y': str(y),
            'colspan': '1',
            'rowspan': '1',
        })
        x += 1
        if x == int(columns):
            x = 0
            y += 1

    return graph_list


def screencreate(url, auth, screen_name, graphids, columns):
    columns = int(columns)
    if len(graphids) % columns == 0:
        vsize = len(graphids) / columns
    else:
        vsize = (len(graphids) / columns) + 1

    values = {'jsonrpc': '2.0',
              'method': 'screen.create',
              'params': [{
                  'name': screen_name,
                  'hsize': columns,
                  'vsize': vsize,
                  'screenitems': []
              }],
              'auth': auth,
              'id': 2
              }
    for i in graphids:
        values['params'][0]['screenitems'].append(i)
    output = requestjson(url, values)


def main():
    url = 'http://servernameorip/api_jsonrpc.php'
    username = 'admin'
    password = 'xxxxxxxxx'
    auth = authenticate(url, username, password)
    host_list = gethosts(groupname, url, auth)
    graph_ids = getgraphs(host_list, graphname, url, auth, columns)
    screencreate(url, auth, screen_name, graph_ids, columns)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-g', dest='groupname', nargs='+', metavar='groupname', type=str,
                        help='which group you want to select')
    parser.add_argument('-G', dest='graphname', nargs='+', metavar='graphname', type=str,
                        help='which graph you want to select')
    parser.add_argument('-c', dest='columns', metavar='columns', type=int, help='the screen columns')
    parser.add_argument('-n', dest='screen_name', metavar='screen_name', type=str, help='the screen name')
    args = parser.parse_args()

    groupname = args.groupname
    graphname = args.graphname
    columns = args.columns
    screen_name = args.screen_name

    main()

#用法
#python create_screen.py - g Hadoop - G 'Network traffic on bond0‘ -c 4 -n ' Hadoop bond0'

#-g
#要显示zabbix的群组。

#-G
#要显示的zabbix图形。

#-c
#显示几列，注意要调整脚本里的：'width': ，'height':  参数来设置大小。

#-n
#在screen 里面显示的名称。
