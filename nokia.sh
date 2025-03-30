
configure {
    aaa {
        radius {
            server-policy "AAA-POLICY" {
                servers {
                    timeout 10
                    retry-count 5
                    router-instance "Base"
                    server 1 {
                        server-name "IXC-RADIUS"
                    }
                }
                acct-on-off {
                }
            }
        }
    }
    card 1 {
        admin-state enable
        mda 1 {
            admin-state enable
            mda-type s18-100gb-qsfp28
        }
    }
    chassis router chassis-number 1 {
        power-shelf 1 {
            power-shelf-type ps-a4-shelf-dc
            power-module 1 {
                power-module-type ps-a-dc-6000
            }
            power-module 2 {
                power-module-type ps-a-dc-6000
            }
            power-module 3 {
                power-module-type ps-a-dc-6000
            }
            power-module 4 {
                power-module-type ps-a-dc-6000
            }
        }
    }
    log {
        filter "1001" {
            named-entry "10" {
                description "Collect only events of major severity or higher"
                action forward
                match {
                    severity {
                        gte major
                    }
                }
            }
        }
        log-id "5" {
            admin-state enable
            source {
                debug true
            }
            destination {
                memory {
                    max-entries 500
                }
            }
        }
        log-id "99" {
            description "Default System Log"
            source {
                main true
            }
            destination {
                memory {
                    max-entries 500
                }
            }
        }
        log-id "100" {
            description "Default Serious Errors Log"
            filter "1001"
            source {
                main true
            }
            destination {
                memory {
                    max-entries 500
                }
            }
        }
    }
    multicast-management {
        chassis-level {
            per-mcast-plane-capacity {
                total-capacity dynamic
                mcast-capacity {
                    primary-percentage 87.5
                    secondary-percentage 87.5
                }
                redundant-mcast-capacity {
                    primary-percentage 87.5
                    secondary-percentage 87.5
                }
            }
        }
    }
    port 1/1/c1 {
        admin-state enable
        connector {
            breakout c1-100g
        }
    }
    port 1/1/c1/1 {
        admin-state enable
    }
    port 1/1/c2 {
        admin-state enable
        connector {
            breakout c1-100g
        }
    }
    port 1/1/c2/1 {
        admin-state enable
        description "pppoe-server"
        ethernet {
            mode hybrid
            encap-type dot1q
        }
    }
    qos {
        md-auto-id {
            qos-policy-id-range {
                start 2
                end 2000
            }
        }
        sap-ingress "UPLOAD" {
            description "QOS UPLOAD"
            default-priority low
            queue 1 {
            }
            queue 11 {
                multipoint true
            }
            policer 1 {
                rate {
                    pir max
                    cir max
                }
            }
            fc "af" {
                policer 1
            }
            fc "be" {
                policer 1
            }
            fc "h1" {
                policer 1
            }
            fc "h2" {
                policer 1
            }
            fc "l1" {
                policer 1
            }
            fc "l2" {
                policer 1
            }
            fc "nc" {
                policer 1
            }
        }
        sap-egress "DOWNLOAD" {
            queue 1 {
                rate {
                    pir max
                    cir max
                }
            }
            fc be {
                queue 1
            }
        }
        sap-egress "default" {
        }
    }
    router "Base" {
        interface "IXC-LINK" {
            port 1/1/c1/1
            ipv4 {
                primary {
                    address 192.168.31.200
                    prefix-length 24
                }
            }
        }
        interface "TO-MK" {
            admin-state enable
        }
        interface "system" {
            admin-state enable
            ipv4 {
                local-dhcp-server "DHCP-CGNAT"
                primary {
                    address 10.0.0.1
                    prefix-length 32
                }
            }
            ipv6 {
                local-dhcp-server "DHCP-V6"
                address 2001:1298:cafe:d758::1 {
                    prefix-length 128
                }
            }
        }
        dhcp-server {
            dhcpv4 "DHCP-CGNAT" {
                admin-state enable
                pool-selection {
                    use-gi-address {
                        scope pool
                    }
                    use-pool-from-client {
                    }
                }
                pool "pool-privado" {
                    minimum-free {
                        percent 3
                    }
                    options {
                        option dns-server {
                            ipv4-address [8.8.8.8]
                        }
                        option lease-time {
                            duration 600
                        }
                    }
                    subnet 100.64.0.0/24 {
                        address-range 100.64.0.2 end 100.64.0.254 {
                        }
                    }
                }
            }
            dhcpv6 "DHCP-V6" {
                admin-state enable
                pool-selection {
                    use-link-address {
                        scope pool
                    }
                    use-pool-from-client {
                    }
                }
                pool "PPPOE-V6" {
                    delegated-prefix {
                        length 64
                    }
                    prefix 2001:1298:fafe::/48 {
                        preferred-lifetime 86400
                        valid-lifetime 86400
                        renew-time 21600
                        rebind-time 36000
                        prefix-type {
                            pd true
                        }
                    }
                    prefix 2804:4f60:cafe::/48 {
                        preferred-lifetime 86400
                        valid-lifetime 86400
                        renew-time 21600
                        rebind-time 36000
                        prefix-type {
                            wan-host true
                        }
                    }
                }
            }
        }
        radius {
            server "IXC-RADIUS" {
                address 10.230.0.195
                secret "C6oGKFNWTYmJKpDEP6eN4HeKJB1j78ut9r9BC1o= hash2"
                accept-coa true
            }
        }
        static-routes {
            route 0.0.0.0/0 route-type unicast {
                next-hop "192.168.31.1" {
                    admin-state enable
                }
            }
        }
    }
    service {
        customer "1" {
        }
        ies "5" {
            admin-state enable
            description "PPP-SERVICE"
            customer "1"
            subscriber-interface "INTERNET" {
                admin-state enable
                ipv4 {
                    allow-unmatching-subnets true
                    address 100.64.0.1 {
                        prefix-length 24
                    }
                }
                ipv6 {
                    allow-unmatching-prefixes true
                    delegated-prefix-length 64
                }
                group-interface "PW-PORT" {
                    admin-state enable
                    radius-auth-policy "AUTH-RADIUS"
                    oper-up-while-empty true
                    ipv4 {
                        urpf-check {
                            mode strict-no-ecmp
                        }
                        dhcp {
                            admin-state enable
                            server [10.0.0.1]
                            trusted true
                            gi-address 100.64.0.1
                            lease-populate {
                                max-leases 131071
                            }
                            client-applications {
                                dhcp true
                                ppp true
                            }
                        }
                    }
                    ipv6 {
                        urpf-check {
                            mode strict-no-ecmp
                        }
                        dhcp6 {
                            pd-managed-route {
                            }
                            relay {
                                admin-state enable
                                server ["2001:1298:cafe:d758::1"]
                                client-applications {
                                    dhcp true
                                    ppp true
                                }
                            }
                        }
                        router-advertisements {
                            admin-state enable
                            options {
                                managed-configuration true
                                other-stateful-configuration true
                            }
                            prefix-options {
                                autonomous true
                            }
                        }
                        router-solicit {
                            admin-state enable
                        }
                    }
                    ipoe-session {
                        admin-state enable
                        ipoe-session-policy "IPOE-POLICY"
                        session-limit 131071
                        sap-session-limit 131071
                    }
                    pppoe {
                        admin-state enable
                        policy "PPPOE-POLICY"
                        session-limit 131071
                        sap-session-limit 131071
                    }
                    local-address-assignment {
                        admin-state enable
                        ipv6 {
                            server "DHCP-V6"
                            client-applications {
                                ppp-slaac true
                            }
                        }
                    }
                }
            }
        }
        vpls "50" {
            admin-state enable
            customer "1"
            capture-sap 1/1/c2/1:* {
                admin-state enable
                radius-auth-policy "AUTH-RADIUS"
                trigger-packet {
                    dhcp true
                    dhcp6 true
                    pppoe true
                }
                msap-defaults {
                    policy "MSAP-DEFAULT"
                    service-name "5"
                    group-interface "PW-PORT"
                }
                ipoe-session {
                    admin-state enable
                    ipoe-session-policy "IPOE-POLICY"
                }
                pppoe {
                    policy "PPPOE-POLICY"
                }
            }
        }
    }
    subscriber-mgmt {
        ipoe-session-policy "IPOE-POLICY" {
            circuit-id-from-auth true
        }
        sub-profile "SUB-DEFAULT" {
            radius-accounting {
                policy ["ACCOUNTING-RADIUS"]
            }
        }
        sla-profile "Policer" {
            egress {
                qos {
                    sap-egress {
                        policy-name "DOWNLOAD"
                    }
                }
            }
            host-limits {
                overall 3
            }
            ingress {
                qos {
                    sap-ingress {
                        policy-name "UPLOAD"
                    }
                }
            }
        }
        sub-ident-policy "SUBSC_ID" {
            sla-profile-map {
                use-direct-map-as-default true
            }
            sub-profile-map {
                use-direct-map-as-default true
            }
        }
        ppp-policy "PPPOE-POLICY" {
            ppp-authentication chap
            ppp-initial-delay true
            ppp-mtu 1500
            keepalive {
                interval 20
                hold-up-multiplier 3
            }
        }
        radius-accounting-policy "ACCOUNTING-RADIUS" {
            radius-server-policy "AAA-POLICY"
            session-id-format number
            queue-instance-accounting {
                admin-state enable
            }
            session-accounting {
                admin-state enable
                interim-update true
                host-update true
            }
            update-interval {
                interval 1200
            }
            include-radius-attribute {
                acct-authentic true
                acct-delay-time true
                called-station-id true
                circuit-id true
                delegated-ipv6-prefix true
                framed-ip-address true
                framed-ip-netmask true
                framed-ipv6-prefix true
                framed-ipv6-route true
                framed-route true
                ipv6-address true
                mac-address true
                nas-identifier true
                remote-id true
                sla-profile true
                std-acct-attributes true
                sub-profile true
                subscriber-id true
                tunnel-server-attrs true
                user-name true
                nas-port {
                    bit-spec "1"
                }
                nas-port-id {
                }
                nas-port-type {
                }
            }
        }
        authentication-origin {
            overrides {
                priority 3 {
                    source radius
                }
            }
        }
        radius-authentication-policy "AUTH-RADIUS" {
            pppoe-access-method pap-chap
            radius-server-policy "AAA-POLICY"
            fallback {
                action {
                    accept
                }
            }
            include-radius-attribute {
                access-loop-options true
                called-station-id true
                circuit-id true
                dhcp-options true
                dhcp-vendor-class-id true
                mac-address true
                nas-identifier true
                pppoe-service-name true
                remote-id true
                tunnel-server-attrs true
                acct-session-id {
                }
                calling-station-id {
                    type mac
                }
                nas-port-id {
                }
            }
        }
        msap-policy "MSAP-DEFAULT" {
            sub-sla-mgmt {
                sub-ident-policy "SUBSC_ID"
                defaults {
                    sla-profile "Policer"
                    sub-profile "SUB-DEFAULT"
                    subscriber-id {
                        auto-id
                    }
                }
            }
        }
    }
    system {
        name "7750-SR1"
        bluetooth {
            advertising-timeout 30
        }
        security {
            telnet-server true
            source-address {
                ipv4 radius {
                    address 192.168.31.200
                }
            }
            management {
                allow-ssh true
            }
            aaa {
                local-profiles {
                    profile "administrative" {
                        default-action permit-all
                        entry 10 {
                            match "configure system security"
                            action permit
                        }
                        entry 20 {
                            match "show system security"
                            action permit
                        }
                        entry 30 {
                            match "tools perform security"
                            action permit
                        }
                        entry 40 {
                            match "tools dump security"
                            action permit
                        }
                        entry 42 {
                            match "tools dump system security"
                            action permit
                        }
                        entry 50 {
                            match "admin system security"
                            action permit
                        }
                        entry 100 {
                            match "configure li"
                            action deny
                        }
                        entry 110 {
                            match "show li"
                            action deny
                        }
                        entry 111 {
                            match "clear li"
                            action deny
                        }
                        entry 112 {
                            match "tools dump li"
                            action deny
                        }
                        netconf {
                            base-op-authorization {
                                action true
                                cancel-commit true
                                close-session true
                                commit true
                                copy-config true
                                create-subscription true
                                delete-config true
                                discard-changes true
                                edit-config true
                                get true
                                get-config true
                                get-data true
                                get-schema true
                                kill-session true
                                lock true
                                validate true
                            }
                        }
                    }
                    profile "default" {
                        entry 10 {
                            match "exec"
                            action permit
                        }
                        entry 20 {
                            match "exit"
                            action permit
                        }
                        entry 30 {
                            match "help"
                            action permit
                        }
                        entry 40 {
                            match "logout"
                            action permit
                        }
                        entry 50 {
                            match "password"
                            action permit
                        }
                        entry 60 {
                            match "show config"
                            action deny
                        }
                        entry 65 {
                            match "show li"
                            action deny
                        }
                        entry 66 {
                            match "clear li"
                            action deny
                        }
                        entry 67 {
                            match "tools dump li"
                            action deny
                        }
                        entry 68 {
                            match "state li"
                            action deny
                        }
                        entry 70 {
                            match "show"
                            action permit
                        }
                        entry 75 {
                            match "state"
                            action permit
                        }
                        entry 80 {
                            match "enable-admin"
                            action permit
                        }
                        entry 90 {
                            match "enable"
                            action permit
                        }
                        entry 100 {
                            match "configure li"
                            action deny
                        }
                    }
                }
            }
            ssh {
                server-cipher-list-v2 {
                    cipher 190 {
                        name aes256-ctr
                    }
                    cipher 192 {
                        name aes192-ctr
                    }
                    cipher 194 {
                        name aes128-ctr
                    }
                    cipher 200 {
                        name aes128-cbc
                    }
                    cipher 205 {
                        name 3des-cbc
                    }
                    cipher 225 {
                        name aes192-cbc
                    }
                    cipher 230 {
                        name aes256-cbc
                    }
                }
                client-cipher-list-v2 {
                    cipher 190 {
                        name aes256-ctr
                    }
                    cipher 192 {
                        name aes192-ctr
                    }
                    cipher 194 {
                        name aes128-ctr
                    }
                    cipher 200 {
                        name aes128-cbc
                    }
                    cipher 205 {
                        name 3des-cbc
                    }
                    cipher 225 {
                        name aes192-cbc
                    }
                    cipher 230 {
                        name aes256-cbc
                    }
                }
                server-mac-list-v2 {
                    mac 200 {
                        name hmac-sha2-512
                    }
                    mac 210 {
                        name hmac-sha2-256
                    }
                    mac 215 {
                        name hmac-sha1
                    }
                    mac 220 {
                        name hmac-sha1-96
                    }
                    mac 225 {
                        name hmac-md5
                    }
                    mac 240 {
                        name hmac-md5-96
                    }
                }
                client-mac-list-v2 {
                    mac 200 {
                        name hmac-sha2-512
                    }
                    mac 210 {
                        name hmac-sha2-256
                    }
                    mac 215 {
                        name hmac-sha1
                    }
                    mac 220 {
                        name hmac-sha1-96
                    }
                    mac 225 {
                        name hmac-md5
                    }
                    mac 240 {
                        name hmac-md5-96
                    }
                }
            }
            user-params {
                local-user {
                    user "admin" {
                        password "$2y$10$TQrZlpBDra86.qoexZUzQeBXDY1FcdDhGWdD9lLxMuFyPVSm0OGy6"
                        restricted-to-home false
                        access {
                            console true
                        }
                        console {
                            member ["administrative"]
                        }
                    }
                    user "ixc" {
                        password "$2y$10$KwpAAWRtwGrHw4p6HF1to.Bb7rSI2uF0ehanoNq/z63a9GLkYVToG"
                        access {
                            ssh-cli true
                        }
                        console {
                            member ["administrative"]
                        }
                    }
                }
            }
        }
    }
}

persistent-indices {
    description "Persistent indices are maintained by the system and must not be modified."
    vrtr-if-id {
        router-name "5" interface-name "INTERNET" vrtr-id 1 if-index 5
        router-name "5" interface-name "PW-PORT" vrtr-id 1 if-index 4
        router-name "Base" interface-name "IXC-LINK" vrtr-id 1 if-index 2
        router-name "Base" interface-name "TO-MK" vrtr-id 1 if-index 3
    }
    sap-ingress-qos-name-id {
        sap-ingress-policy-name "UPLOAD" policy-id 2
    }
    sap-egress-qos-name-id {
        sap-egress-policy-name "DOWNLOAD" policy-id 2
    }
    msap-policy-id {
        name "MSAP-DEFAULT" id 1
    }
    log-name-id {
        log-name "5" log-id 5 context 1 vrtr-id 1
    }
}

# Finished 2025-03-30T18:52:09.1+00:00
