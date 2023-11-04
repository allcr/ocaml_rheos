open Lwt
open Lwt_unix
open Unix

let ssdp_addr = "239.255.255.250"
let ssdp_port = 1900
let ssdp_mx = 3 (* The maximum wait time in seconds *)
let ssdp_st = "ssdp:all" (* The search target for all devices and services *)

let discovery_message =
  Printf.sprintf
    "M-SEARCH * HTTP/1.1\r\n\
     HOST: %s:%d\r\n\
     MAN: \"ssdp:discover\"\r\n\
     MX: %d\r\n\
     ST: %s\r\n\
     \r\n"
    ssdp_addr ssdp_port ssdp_mx ssdp_st

let buffer = Bytes.create 1024
let broadcast_addr = Unix.inet_addr_of_string ssdp_addr
let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_DGRAM
let () = Lwt_unix.bind sock (Lwt_unix.ADDR_INET (Unix.inet_addr_any, 0))
let () = Lwt_unix.mcast_set_ttl sock 2
let () = Lwt_unix.mcast_set_loop sock true

let send_req () =
  let addr = Lwt_unix.ADDR_INET (broadcast_addr, sddp_port) in
  Lwt_unix.sendto sock
    (Bytes.of_string discovery_message)
    0
    (String.length discovery_message)
    [] addr
  >>= fun _ ->
  Lwt.return_unit Lwt_unix.recvfrom sock buffer 0 (Bytes.length buffer) []
