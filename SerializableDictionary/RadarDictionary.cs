using FrameWork;
using System;
using UnityEngine;

namespace Game
{
    public enum RadarMeshType : int
    {
        NORMAL,
        DEATH,
        DAMAGED,
        OPENED,
        EMPTY,
        TYPENUM,
    }

    [Serializable]
    public class RadarChangeType : SerializableDictionary<RadarMeshType, Mesh> { }

}
