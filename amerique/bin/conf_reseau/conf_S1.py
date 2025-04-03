import pexpect  


def configure_s1():


    # Open the configuration file
    minicom_cmd = f"minicom "

    command =[
        "conf t",
        "version 15.2",
        "no service pad",
        "service timestamps debug datetime msec",
        "service timestamps log datetime msec",
        "no service password-encryption",
        "hostname S1",
        "no aaa new-model",
        "system mtu routing 1500",
        "spanning-tree mode rapid-pvst",
        "spanning-tree extend system-id",
        "vlan internal allocation policy ascending",
        "interface FastEthernet0/1",
        "switchport access vlan 57",
        "switchport mode access",
        "interface FastEthernet0/2",
        "switchport access vlan 58",
        "switchport mode access",
        "interface FastEthernet0/3",
        "switchport access vlan 59",
        "switchport mode access",
        "interface FastEthernet0/24",
        "switchport mode trunk",
        "interface Vlan1",
        "no ip address",
        "ip http server",
        "ip http secure-server",
        "line con 0",
        "line vty 5 15",
        "end"
    ]

    try:
        child = pexpect.spawn(minicom_cmd, timeout=10)
        child.expect(">")
        child.sendline("enable")
        child.expect("#")

        for cmd in command:
            child.sendline(cmd)
            child.expect("#")

        print("configuration done")
        child.sendline("exit")
        child.expect(">")
        child.sendline("exit")
        child.expect(pexpect.EOF)
        child.close()
    except Exception as e:
        print("Error: ", e)
    
if __name__ == "__main__":
    configure_s1()
       

