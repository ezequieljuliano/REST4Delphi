unit REST4D.Mapping;

interface

uses
  ObjectsMappers;

type

  Mapper = class(ObjectsMappers.Mapper)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  MapperTransientAttribute = ObjectsMappers.MapperTransientAttribute;
  DoNotSerializeAttribute = ObjectsMappers.DoNotSerializeAttribute;
  MapperItemsClassType = ObjectsMappers.MapperItemsClassType;
  MapperListOf = ObjectsMappers.MapperListOf;

implementation

end.
