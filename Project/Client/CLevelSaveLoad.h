#pragma once


class CLevel;
class CLayer;
class CGameObject;

class CLevelSaveLoad
{
public:
	static void SaveLevel(CLevel* _Level, const wstring& _strLevelPath);
	static void SaveLayer(CLayer* _Layer, FILE* _File);
	static void SaveLayer(CLayer* _Layer, ofstream& fout);
	static void SaveGameObject(CGameObject* _Obj, FILE* _File);
	static void SaveGameObject(CGameObject* _Obj, ofstream& fout);


	static CLevel* LoadLevel(const wstring& _strLevelPath);
	static void LoadLayer(CLayer* _Layer, FILE* _File);
	static CGameObject* LoadGameObject(FILE* _File);
};

