abstract class TodoStates{}
class InitialState extends TodoStates{}

class ChangeBottomIndexState extends TodoStates{}
class DatabaseCreatedState extends TodoStates {}
class CreateDatabaseState        extends TodoStates {}
class InsertDatabaseState        extends TodoStates {}
class GetDatabaseLoadingState    extends TodoStates {}
class GetDatabaseSuccessState    extends TodoStates {}
class UpdateDatabaseState      extends TodoStates {}
class DeleteDatabaseState      extends TodoStates {}