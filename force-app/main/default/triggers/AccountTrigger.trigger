trigger AccountTrigger on Account(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after undelete,
  after delete
) {
  System.debug('OperationType' + Trigger.OperationType);
  TriggerDispatcher.run(new AccountTriggerHandler(), Trigger.OperationType);
}
