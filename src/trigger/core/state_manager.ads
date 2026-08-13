-- src/state_manager.ads (Draft SPARK Annotations)
pragma SPARK_Mode (On);

package State_Manager is

   type Agent_State is (Idle, Authenticating, Rate_Limited, Reporting);

   -- Ghost state for proofs
   Current_State : Agent_State := Idle
     with Ghost;

   -- Represents the duration remaining in a FloodWait
   Wait_Timeout : Natural := 0
     with Ghost;

   -- A session record (simplified for proof modeling)
   type Session_Rec is private;

   function Is_Valid (S : Session_Rec) return Boolean;

   -----------------------------------------------------------------------------
   --  API Dispatch
   -----------------------------------------------------------------------------

   -- Precondition ensures we NEVER call the API if Rate_Limited
   procedure Dispatch_Report (S : in out Session_Rec)
     with 
       Global  => (In_Out => Current_State),
       Pre     => Current_State = Reporting and then Is_Valid (S),
       Depends => (S => S, Current_State => Current_State);

   -----------------------------------------------------------------------------
   --  State Transitions
   -----------------------------------------------------------------------------

   procedure Enter_Flood_Wait (Timeout_Seconds : Natural)
     with
       Global => (In_Out => (Current_State, Wait_Timeout)),
       Post   => Current_State = Rate_Limited and Wait_Timeout = Timeout_Seconds;

   procedure Resume_From_Wait
     with
       Global => (In_Out => (Current_State, Wait_Timeout)),
       Pre    => Current_State = Rate_Limited and Wait_Timeout = 0,
       Post   => Current_State = Idle;

private
   type Session_Rec is record
      -- Implementation hidden
      Initialized : Boolean := False;
   end record;

   function Is_Valid (S : Session_Rec) return Boolean is (S.Initialized);

end State_Manager;
