(*
 * Copyright 2003-2006 Savonet team
 *
 * This file is part of Ocaml-speex.
 *
 * Ocaml-speex is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Ocaml-speex is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Ocaml-speex; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

(**
  * Functions for manipulating speex audio data using libspeex.
  *
  * @author Romain Beauxis
  *)

exception Invalid_frame_size

type mode = Narrowband | Wideband | Ultra_wideband

(* Generated by control_define *)
type control =
  | (* Reset the encoder/decoder memories to zero *)
    SPEEX_RESET_STATE
  | (* Set/get enhancement on/off (decoder only) *)
    SPEEX_SET_ENH
  | SPEEX_GET_ENH
  | (* Obtain frame size used by encoder/decoder *)
    SPEEX_GET_FRAME_SIZE
  | (* Set/get quality value *)
    SPEEX_SET_QUALITY
  | (* Set/get sub-mode to use *)
    SPEEX_SET_MODE
  | SPEEX_GET_MODE
  | (* Set/get low-band sub-mode to use (wideband only)*)
    SPEEX_SET_LOW_MODE
  | SPEEX_GET_LOW_MODE
  | (* Set/get high-band sub-mode to use (wideband only)*)
    SPEEX_SET_HIGH_MODE
  | SPEEX_GET_HIGH_MODE
  | (* Set/get VBR on (1) or off (0) *)
    SPEEX_SET_VBR
  | SPEEX_GET_VBR
  | (* Set/get quality value for VBR encoding (0-10) *)
    SPEEX_SET_VBR_QUALITY
  | SPEEX_GET_VBR_QUALITY
  | (* Set/get complexity of the encoder (0-10) *)
    SPEEX_SET_COMPLEXITY
  | SPEEX_GET_COMPLEXITY
  | (* Set/get bitrate *)
    SPEEX_SET_BITRATE
  | SPEEX_GET_BITRATE
  | (* Set/get sampling rate *)
    SPEEX_SET_SAMPLING_RATE
  | SPEEX_GET_SAMPLING_RATE
  | (* Set/get VAD status (1 for on, 0 for off) *)
    SPEEX_SET_VAD
  | SPEEX_GET_VAD
  | (* Set/get Average Bit-Rate (ABR) to n bits per seconds *)
    SPEEX_SET_ABR
  | SPEEX_GET_ABR
  | (* Set/get DTX status (1 for on, 0 for off) *)
    SPEEX_SET_DTX
  | SPEEX_GET_DTX
  | (* Set/get submode encoding in each frame (1 for yes, 0 for no, setting to no breaks the standard) *)
    SPEEX_SET_SUBMODE_ENCODING
  | SPEEX_GET_SUBMODE_ENCODING
  | (* Set/get tuning for packet-loss concealment (expected loss rate) *)
    SPEEX_SET_PLC_TUNING
  | SPEEX_GET_PLC_TUNING
  | (* Set/get the max bit-rate allowed in VBR mode *)
    SPEEX_SET_VBR_MAX_BITRATE
  | SPEEX_GET_VBR_MAX_BITRATE
  | (* Turn on/off input/output high-pass filtering *)
    SPEEX_SET_HIGHPASS
  | SPEEX_GET_HIGHPASS
  | (* Get "activity level" of the last decoded frame, i.e.
       how much damage we cause if we remove the frame *)
    SPEEX_GET_ACTIVITY

module Header : sig
  (** Type for speex header. *)
  type t = {
    id : string;
    version : string;
    version_id : int;
    header_size : int;
    rate : int;
    mode : mode;
    mode_bitstream_version : int;
    nb_channels : int;
    bitrate : int;
    frame_size : int;
    vbr : bool;
    frames_per_packet : int;
    extra_headers : int;
  }

  (* Defined in speex_header.h *)
  val header_string_length : int
  val header_version_length : int

  (** Initiate a new speex header. *)
  val init :
    ?frames_per_packet:int ->
    ?mode:mode ->
    ?vbr:bool ->
    nb_channels:int ->
    rate:int ->
    unit ->
    t

  (** [encode_header_packetout header metadata]: output ogg packets containing the header. 
    * First packet contains speex audio codec settings, second the metadata. *)
  val encode_header_packetout :
    t -> (string * string) list -> Ogg.Stream.packet * Ogg.Stream.packet

  (** Output ogg packets containing the header and put them into the given stream. *)
  val encode_header : t -> (string * string) list -> Ogg.Stream.stream -> unit

  (** Decode the speex header contained in the given packet. 
    * 
    * Raises [Invalid_argument] if the packet does not contain speex audio codec data. *)
  val header_of_packet : Ogg.Stream.packet -> t

  (** Decode the metadata contained in the given packet. 
    * 
    * Raises [Invalid_argument] if the packet does not contain speex metadata. *)
  val comments_of_packet : Ogg.Stream.packet -> string * (string * string) list
end

module Encoder : sig
  (** Opaque type for the speex encoder. *)
  type t

  (** Initiate a new encoder. *)
  val init : mode -> int -> t

  (** Get a parameter. *)
  val get : t -> control -> int

  (** Set a parameter. *)
  val set : t -> control -> int -> unit

  (** [encode_page encoder stream f]: calls [f] to get audio data and encode it until a page is ready. 
    *
    * Known issue: float expected values seem not to be in [-1..1] but in
    * [-32768..32767] which does not seem to be correct. *)
  val encode_page :
    t -> Ogg.Stream.stream -> (unit -> float array) -> Ogg.Page.t

  (** Same as [encode_page] except that it encodes stereo data into mono. *)
  val encode_page_stereo :
    t -> Ogg.Stream.stream -> (unit -> float array array) -> Ogg.Page.t

  (** Same as [encode_page] but using integers. *)
  val encode_page_int :
    t -> Ogg.Stream.stream -> (unit -> int array) -> Ogg.Page.t

  (** Same as [encode_page_stereo] but using integers. *)
  val encode_page_int_stereo :
    t -> Ogg.Stream.stream -> (unit -> int array array) -> Ogg.Page.t

  (** Set the end of stream for this stream. *)
  val eos : t -> Ogg.Stream.stream -> unit
end

module Decoder : sig
  (** Opaque type for the speex decoder. *)
  type t

  (** Initiate a new decoder. *)
  val init : mode -> t

  (** Get a setting. *)
  val get : t -> control -> int

  (** Set a setting. *)
  val set : t -> control -> int -> unit

  (** Decode data. *)
  val decode : t -> Ogg.Stream.stream -> float array list

  (** Decode stereo data. *)
  val decode_stereo : t -> Ogg.Stream.stream -> float array array list

  (** Decode data, passing them to the given feed. *)
  val decode_feed : t -> Ogg.Stream.stream -> (float array -> unit) -> unit

  (** Decode stereo data, passing them to the given feed. *)
  val decode_feed_stereo :
    t -> Ogg.Stream.stream -> (float array array -> unit) -> unit

  (** Same as [decode] but with integers. *)
  val decode_int : t -> Ogg.Stream.stream -> int array list

  (** Same as [decode_stereo] but with integers. *)
  val decode_int_stereo : t -> Ogg.Stream.stream -> int array array list

  (** Same as [decode_feed] but with integers. *)
  val decode_int_feed : t -> Ogg.Stream.stream -> (int array -> unit) -> unit

  (** Same as [decode_feed_stereo] but with integers. *)
  val decode_int_feed_stereo :
    t -> Ogg.Stream.stream -> (int array array -> unit) -> unit
end

module Wrapper : sig
  (** High level wrappers for speex. *)

  module Decoder : sig
    (** High level wrapper to easily decode speex files. *)

    exception Not_speex

    (** Opaque type for the decoder. *)
    type t

    (** Type for data read. Same signature as [Unix.read]. *)
    type read = bytes -> int -> int -> int

    (** Open the passed [Ogg.Sync] as a new speex stream. *)
    val open_sync : Ogg.Sync.t -> t

    (** Open the passed file name as a new speex stream. *)
    val open_file : string -> t * Unix.file_descr

    (** Open the passed feed as a new speex stream. *)
    val open_feed : read -> t

    (** Get the serial of the stream currently being decoded.
      * This value may change if the stream contains sequentialized ogg streams. *)
    val serial : t -> nativeint

    (** Get current comments. *)
    val comments : t -> (string * string) list

    (** Get current header. *)
    val header : t -> Header.t

    (** Decode audio data. *)
    val decode : t -> float array list

    (** Decode stereo audio data. *)
    val decode_stereo : t -> float array array list

    (** Decode audio data, passing it to a feed. *)
    val decode_feed : t -> (float array -> unit) -> unit

    (** Same as [decode_feed] but with stereo data. *)
    val decode_feed_stereo : t -> (float array array -> unit) -> unit

    (** Same as [decode] but with integers. *)
    val decode_int : t -> int array list

    (** Same as [decode_stereo] but with integers. *)
    val decode_int_stereo : t -> int array array list

    (** Same as [decode_feed] but with integers. *)
    val decode_int_feed : t -> (int array -> unit) -> unit

    (** Same as [decode_int_feed_stereo] but with integers. *)
    val decode_int_feed_stereo : t -> (int array array -> unit) -> unit
  end
end

module Skeleton : sig
  (** Generate a vorbis fisbone packet with
    * these parameters, to use in an ogg skeleton.
    * Default value for [start_granule] is [Int64.zero],
    * Default value for [headers] is ["Content-type","audio/speex"]
    *
    * See: http://xiph.org/ogg/doc/skeleton.html. *)
  val fisbone :
    ?start_granule:Int64.t ->
    ?headers:(string * string) list ->
    serialno:nativeint ->
    header:Header.t ->
    unit ->
    Ogg.Stream.packet
end
