using System.Net.Sockets;
using PracManCore.Exceptions;
using PracManCore.Scripting;
using PracManCore.Target.API;

namespace PracManCore.Target;

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

internal struct Pcsx2MemorySubItem {
    public uint Address;
    public uint Size;
    public Target.MemoryCondition Condition;
    public bool Freeze;
    public bool Released;
    public byte[]? LastValue;
    public byte[] SetValue;
    public Action<byte[]> Callback;
}

public class PCSX2(string slot) : Target(slot) {
    public new static string Name() {
        return "PCSX2";
    }
    
    public new static string PlaceholderAddress() {
        return "28012";
    }
    
    public new static void DiscoverTargets(DicoveredTargetsCallback callback) {
        List<string> targets = [];
        
        // If not Windows, look for .sock files in /tmp
        if (Environment.OSVersion.Platform != PlatformID.Win32NT) {
            string tmpDir = Environment.GetEnvironmentVariable("TMPDIR") ?? "/tmp";
            string[] files = Directory.GetFiles(tmpDir, "pcsx2.sock.*");
            foreach (string file in files) {
                string[] parts = file.Split('.');
                if (parts.Length == 3) {
                    targets.Add(parts[2]);
                }
            }
        }
        
        callback(targets);
    }

    private PINE? _pine;
    private readonly List<Pcsx2MemorySubItem> _subItems = [];
    private readonly Mutex _subMutex = new(false);
    private bool _memoryWorkerStarted = false;

    public override bool Start(AttachedCallback callback)
    {
        Log($"[Ratchet2.Start] Called with address '{_address}'");

        if (!int.TryParse(_address, out int slot))
        {
            Log("[Ratchet2.Start] Invalid slot address");
            callback(false, "Invalid slot");
            return false;
        }

        try
        {
            _pine = new PINE(slot);
            Log("[Ratchet2.Start] PINE instance created");

            callback(true, null);
            Application.ActiveTargets.Add(this);
            Log("[Ratchet2.Start] Target added to ActiveTargets");

            return true;
        }
        catch (SocketException ex)
        {
            Log($"[Ratchet2.Start] SocketException: {ex.Message}");
            callback(false, $"Couldn't open IPC port {slot}. Did you enable IPC in PCSX2 (Advanced -> PINE)? Make sure the port is correct and not already in use.");
            return false;
        }
        catch (Exception ex)
        {
            Log($"[Ratchet2.Start] Exception: {ex.Message}");
            callback(false, "Unknown error: " + ex.Message);
            return false;
        }
    }



    public override bool Stop() {
        base.Stop();

        _memoryWorkerStarted = false;

        try {
            _pine?.Close();
            return true;
        }
        catch (Exception ex) {
            Console.WriteLine($"Disconnection failed: {ex.Message}");
            return false;
        }
    }

    public override int GetCurrentPID() {
        if (_pine == null) {
            return 0;
        }
        
        try {
            var status = _pine.Status();
            return status == EmulatorStatus.SHUTDOWN ? 0 : 1;
        }
        catch {
            return 0;
        }
    }

    private bool ReconnectPine(int retries = 3, int delayMs = 500)
    {
        for (int attempt = 1; attempt <= retries; attempt++)
        {
            try
            {
                Log($"[ReconnectPine] Tentative {attempt} de reconnexion");

                if (!int.TryParse(_address, out int slot))
                    return false;

                _pine?.Close();
                _pine = new PINE(slot);

                if (_pine.IsConnected())
                {
                    // Test le backend
                    try
                    {
                        var status = _pine.Status(); // ou _pine.GameId(), si Status() pas dispo
                        Log("[ReconnectPine] Connexion réussie et backend actif");
                        return true;
                    }
                    catch (Exception ex)
                    {
                        Log($"[ReconnectPine] Backend inactif après connexion : {ex.Message}");
                    }
                }
                else
                {
                    Log("[ReconnectPine] _pine.IsConnected() == false");
                }
            }
            catch (Exception ex)
            {
                Log($"[ReconnectPine] Exception à l’essai {attempt} : {ex.Message}");
            }

            Thread.Sleep(delayMs);
        }

        Log("[ReconnectPine] Toutes les tentatives échouées");
        return false;
    }



    public override string GetGameTitleID()
    {
        Log("[GetGameTitleID] Appelé");

        if (_pine == null)
        {
            Log("[GetGameTitleID] _pine est null");
            throw new TargetException("Can't get title: Not connected");
        }

        if (!_pine.IsConnected())
        {
            Log("[GetGameTitleID] PINE non connecté, tentative de reconnexion");
            if (!ReconnectPine())
            {
                Log("[GetGameTitleID] Reconnexion échouée");
                throw new TargetException("Can't get title: PINE not connected");
            }
        }

        try
        {
            Log("[GetGameTitleID] Appel à _pine.GameId()");
            string gameId = _pine.GameId();
            Log("[GetGameTitleID] GameId = " + gameId);
            return string.IsNullOrEmpty(gameId) ? "" : gameId;
        }
        catch (IOException ex)
        {
            Log("[GetGameTitleID] IOException capturée : " + ex.Message);
            Log("[GetGameTitleID] Tentative de reconnexion suite à IOException");

            if (ReconnectPine())
            {
                try
                {
                    string gameId = _pine.GameId();
                    Log("[GetGameTitleID] GameId après reconnexion = " + gameId);
                    return string.IsNullOrEmpty(gameId) ? "" : gameId;
                }
                catch (Exception retryEx)
                {
                    Log("[GetGameTitleID] Échec après reconnexion : " + retryEx.Message);
                    throw new TargetException("Can't get title: PINE reconnection failed");
                }
            }
            else
            {
                throw new TargetException("Can't get title: Reconnection failed");
            }
        }
        catch (Exception ex)
        {
            Log("[GetGameTitleID] Exception capturée : " + ex.Message);
            throw new TargetException("Can't get title: PINE error");
        }
    }






    public override int MemSubIDForAddress(uint address) {
        throw new NotImplementedException();
    }

    public override void Notify(string message) {
        Application.Delegate?.Alert("Notification", message);
    }

    public override byte[] ReadMemory(uint address, uint size) {
        if (_pine == null) {
            throw new TargetException("Can't read memory: Not connected");
        }
        
        try {
            uint adjustedAddress = address;
            return _pine.Read(adjustedAddress, (int)size);
        }
        catch (Exception ex) {
            Console.WriteLine($"ReadMemory failed: {ex.Message}");
            return new byte[size];
        }
    }

    public override void WriteMemory(uint address, uint size, byte[] memory) {
        if (_pine == null) {
            throw new TargetException("Can't write memory: Not connected");
        }
        
        try {
            uint adjustedAddress = address;
            _pine.Write(adjustedAddress, memory);
        }
        catch (Exception ex) {
            Console.WriteLine($"WriteMemory failed: {ex.Message}");
        }
    }

    public override void ReleaseSubID(int memSubID) {
        if (memSubID < 0 || memSubID >= _subItems.Count)
            return;

        var subItem = _subItems[memSubID];
        subItem.Released = true;

        _subMutex.WaitOne();
        _subItems[memSubID] = subItem;
        _subMutex.ReleaseMutex();
    }

    public override int SubMemory(uint address, uint size, MemoryCondition condition, byte[] memory,
        Action<byte[]> callback) {
        var item = new Pcsx2MemorySubItem {
            Address = address,
            Size = size,
            Condition = condition,
            Callback = callback,
            SetValue = memory,
            Freeze = false
        };

        _subMutex.WaitOne();
        _subItems.Add(item);
        _subMutex.ReleaseMutex();

        if (!_memoryWorkerStarted) {
            StartMemorySubWorker();
        }

        return _subItems.Count - 1;
    }

    public override int FreezeMemory(uint address, uint size, MemoryCondition condition, byte[] memory) {
        var item = new Pcsx2MemorySubItem {
            Address = address,
            Size = size,
            Condition = condition,
            SetValue = memory,
            Freeze = true
        };

        _subMutex.WaitOne();
        _subItems.Add(item);
        _subMutex.ReleaseMutex();

        if (!_memoryWorkerStarted) {
            StartMemorySubWorker();
        }

        return _subItems.Count - 1;
    }

    private void MemorySubWorker() {
        _memoryWorkerStarted = true;

        while (_memoryWorkerStarted) {
            _subMutex.WaitOne();

            for (int i = 0; i < _subItems.Count; i++) {
                var item = _subItems[i];

                if (item.Released)
                    continue;

                bool hitConditional = false;
                byte[] currentValue = ReadMemory(item.Address, item.Size);
                
                int setValueInt = 0;
                if (item.SetValue.Length == 4) setValueInt = BitConverter.ToInt32(item.SetValue.Reverse().ToArray(), 0);
                if (item.SetValue.Length == 2) setValueInt = BitConverter.ToInt16(item.SetValue.Reverse().ToArray(), 0);
                if (item.SetValue.Length == 1) setValueInt = item.SetValue[0];
                
                int currentValueInt = 0;
                if (currentValue.Length == 4) currentValueInt = BitConverter.ToInt32(currentValue.Reverse().ToArray(), 0);
                if (currentValue.Length == 2) currentValueInt = BitConverter.ToInt16(currentValue.Reverse().ToArray(), 0);
                if (currentValue.Length == 1) currentValueInt = currentValue[0];

                if (item.Condition == MemoryCondition.Any) {
                    hitConditional = true;
                } else if (item.Condition == MemoryCondition.Changed) {
                    if (item.LastValue == null) {
                        hitConditional = true;
                    } else if (!currentValue.SequenceEqual(item.LastValue)) {
                        hitConditional = true;
                    }
                } else if (item.Condition == MemoryCondition.Above) {
                    if (currentValueInt > setValueInt) {
                        hitConditional = true;
                    }
                } else if (item.Condition == MemoryCondition.Below) {
                    if (currentValueInt < setValueInt) {
                        hitConditional = true;
                    }
                } else if (item.Condition == MemoryCondition.Equal) {
                    if (currentValueInt == setValueInt) {
                        hitConditional = true;
                    }
                } else if (item.Condition == MemoryCondition.NotEqual) {
                    if (currentValueInt != setValueInt) {
                        hitConditional = true;
                    }
                }

                if (hitConditional) {
                    if (item.Freeze) {
                        WriteMemory(item.Address, item.Size, item.SetValue);
                    } else {
                        Application.Delegate?.RunOnMainThread(() => {
                            item.Callback.Invoke(currentValue.Reverse().ToArray());
                        });
                    }
                }

                item.LastValue = currentValue;
                _subItems[i] = item;
            }

            _subMutex.ReleaseMutex();
            Thread.Sleep(1000 / 120); // Adjust as needed
        }
    }

    private void StartMemorySubWorker() {
        Thread thread = new Thread(MemorySubWorker);
        thread.Start();
    }

    public static void Log(string message)
    {
        File.AppendAllText("C:\\temp\\pracman.log", $"{DateTime.Now:HH:mm:ss.fff} - {message}\n");
    }

    private void StopMemorySubWorker() {
        _memoryWorkerStarted = false;
    }
}