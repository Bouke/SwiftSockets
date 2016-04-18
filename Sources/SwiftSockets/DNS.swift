//
//  DNS.swift
//  SwiftSockets
//
//  Created by Helge Hess on 7/3/14.
//  Copyright (c) 2014-2015 Always Right Institute. All rights reserved.
//
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public func gethoztbyname<T: SocketAddress>
  (name : String, flags : Int32 = AI_CANONNAME,
   cb   : ( String, String?, T? ) -> Void)
{
  // Note: I can't just provide a name and a cb, swiftc will complain.
  var hints = addrinfo()
  hints.ai_flags  = flags  // AI_CANONNAME, AI_NUMERICHOST, etc
  hints.ai_family = T.domain
  
  var ptr = UnsafeMutablePointer<addrinfo>(nil)
  defer { freeaddrinfo(ptr) } /* free OS resources (TBD: works with nil?) */
  
  /* run lookup (synchronously, can be slow!) */
  // b3: (cs : CString) doesn't pick up the right overload?
  let rc = getaddrinfo(name, nil, &hints, &ptr)

  guard rc == 0 else {
    cb(name, nil, nil)
    return
  }
  
  /* copy results - we just take the first match */
  var cn   : String? = nil
#if swift(>=3.0)
  var addr : T?      = ptr?.pointee.address()
  if rc == 0 && ptr != nil {
    cn   = ptr!.pointee.canonicalName
    addr = ptr!.pointee.address()
  }
#else
  var addr : T?      = ptr.memory.address()
  if rc == 0 && ptr != nil {
    cn   = ptr.memory.canonicalName
    addr = ptr.memory.address()
  }
#endif
  
  /* report results */
  cb(name, cn, addr)
}


/**
 * This is awkward :-) But it actually works. Though it is not what you want,
 * the address here should be dynamic depending on the domain of the C struct.
 *
 * Whatever, this runs:
 *   let hhost : String = "mail.google.com" // why is this necessary?
 *   gethostzbyname(hhost, flags: Int32(AI_CANONNAME)) {
 *     ( cn: String, infos: [ ( cn: String?, address: sockaddr_in? )]? ) -> Void
 *     in
 *     print("result \(cn): \(infos)")
 *   }
 *
 * TBD: The 'flags' has to be provided, otherwise the trailing closure is not
 *      detected right?
 */
public func gethostzbyname<T: SocketAddress>
  (name : String, flags : Int32 = AI_CANONNAME,
   cb   : ( String, [ ( cn: String?, address: T? ) ]? ) -> Void
  ) -> Void
{
  // Note: I can't just provide a name and a cb, swiftc will complain.
  var hints = addrinfo()
  hints.ai_flags  = flags  // AI_CANONNAME, AI_NUMERICHOST, etc
  hints.ai_family = T.domain
  
  var ptr = UnsafeMutablePointer<addrinfo>(nil)
  defer { freeaddrinfo(ptr) } /* free OS resources (TBD: works with nil?) */
  
  /* run lookup (synchronously, can be slow!) */
  let rc = getaddrinfo(name, nil, &hints, &ptr)
  guard rc == 0 else {
    cb(name, nil)
    return
  }
  
  /* copy results - we just take the first match */
  typealias hapair = (cn: String?, address: T?)
  var results : Array<hapair>! = nil
  
  if rc == 0 && ptr != nil {
    var pairs = Array<hapair>()
#if swift(>=3.0)
    for info in ptr!.pointee {
      let pair : hapair = ( info.canonicalName, info.address() )
      pairs.append(pair)
    }
#else
    for info in ptr!.memory {
      let pair : hapair = ( info.canonicalName, info.address() )
      pairs.append(pair)
    }
#endif
    results = pairs
  }
  
  /* report results */
  
  cb(name, results)
}
