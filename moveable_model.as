/**
 * @file moveable_model.as
 * @brief Standalone moveable model entity for Sven Co-op maps.
 */

namespace MoveableModel
{
    class CMoveableModel : ScriptBaseAnimating
    {
        private EHandle m_hHolder;
        private bool m_bIsHeld = false;
        private bool m_bCanMove = true;
        private bool m_bUseBounce = false;
        private bool m_bAllowAttackPull = false;
        private bool m_bAllowAttackPush = false;
        private bool m_bSyncAngles = false;

        private int m_iAnimSequence = 0;
        private string m_szAllowedTarget;
        private string m_szMins;
        private string m_szMaxs;
        private float m_flEffectFriction = 100.0f;

        // Held-prop carry tuning. LMB/RMB optionally adjusts this distance when enabled.
        private float m_flHoldDistance = 64.0f;
        private float m_flMinHoldDist = 32.0f;
        private float m_flMaxHoldDist = 512.0f;
        private float m_flScrollSpeed = 18.0f;

        private Vector m_vecMins;
        private Vector m_vecMaxs;

        int ObjectCaps() { return FCAP_IMPULSE_USE; }

        void Spawn()
        {
            self.pev.solid = SOLID_BBOX;
            self.pev.movetype = m_bUseBounce ? MOVETYPE_BOUNCE : MOVETYPE_TOSS;
            self.pev.friction = m_flEffectFriction / 100.0f;
            self.pev.gravity = 1.0f;

            Precache();

            string modelPath = self.pev.model;
            if (modelPath.IsEmpty())
            {
                g_Game.AlertMessage(at_console, "moveable_model: No model specified; removing entity.\n");
                g_EntityFuncs.Remove(self);
                return;
            }

            g_EntityFuncs.SetModel(self, self.pev.model);

            if (self.pev.scale <= 0.01f) self.pev.scale = 1.0f;

            if (!m_szMins.IsEmpty()) g_Utility.StringToVector(m_vecMins, m_szMins);
            else m_vecMins = Vector(-12, -12, 0);

            if (!m_szMaxs.IsEmpty()) g_Utility.StringToVector(m_vecMaxs, m_szMaxs);
            else m_vecMaxs = Vector(12, 12, 72);

            m_vecMins = m_vecMins * self.pev.scale;
            m_vecMaxs = m_vecMaxs * self.pev.scale;

            g_EntityFuncs.SetSize(self.pev, m_vecMins, m_vecMaxs);
            g_EntityFuncs.SetOrigin(self, self.pev.origin);

            self.pev.sequence = m_iAnimSequence;
            self.pev.frame = 0;
            self.ResetSequenceInfo();
            self.InitBoneControllers();

            SetThink(ThinkFunction(this.Think));
            SetTouch(TouchFunction(this.ModelTouch));
            SetUse(UseFunction(this.ModelUse));
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        void Precache()
        {
            string modelPath = self.pev.model;
            if (!modelPath.IsEmpty()) g_Game.PrecacheModel(modelPath);
            BaseClass.Precache();
        }

        bool KeyValue(const string& in szKey, const string& in szValue)
        {
            if (szKey == "canmove") m_bCanMove = atoi(szValue) != 0;
            else if (szKey == "anim") m_iAnimSequence = atoi(szValue);
            else if (szKey == "min_size") m_szMins = szValue;
            else if (szKey == "max_size") m_szMaxs = szValue;
            else if (szKey == "allowedtarget") m_szAllowedTarget = szValue;
            else if (szKey == "effect_friction") m_flEffectFriction = atof(szValue);
            else if (szKey == "usebounce") m_bUseBounce = atoi(szValue) != 0;
            else if (szKey == "scale") self.pev.scale = atof(szValue);
            else if (szKey == "attack_pull") m_bAllowAttackPull = atoi(szValue) != 0;
            else if (szKey == "attack_push") m_bAllowAttackPush = atoi(szValue) != 0;
            else if (szKey == "sync_angles") m_bSyncAngles = atoi(szValue) != 0;
            else return BaseClass.KeyValue(szKey, szValue);
            return true;
        }

        void Think()
        {
            if (self.pev.sequence != m_iAnimSequence)
            {
                self.pev.sequence = m_iAnimSequence;
                self.ResetSequenceInfo();
            }
            self.StudioFrameAdvance();

            if (m_bIsHeld)
            {
                CBaseEntity@ holderEnt = m_hHolder.GetEntity();
                CBasePlayer@ player = cast<CBasePlayer@>(holderEnt);
                if (player is null || !player.IsConnected() || !player.IsAlive())
                {
                    Drop();
                    return;
                }

                int buttons = player.pev.button;
                if ((buttons & IN_USE) == 0)
                {
                    Drop();
                    return;
                }

                if (m_bAllowAttackPush && (buttons & IN_ATTACK) != 0)
                {
                    m_flHoldDistance += m_flScrollSpeed;
                    if (m_flHoldDistance > m_flMaxHoldDist) m_flHoldDistance = m_flMaxHoldDist;
                }
                else if (m_bAllowAttackPull && (buttons & IN_ATTACK2) != 0)
                {
                    m_flHoldDistance -= m_flScrollSpeed;
                    if (m_flHoldDistance < m_flMinHoldDist) m_flHoldDistance = m_flMinHoldDist;
                }

                g_EngineFuncs.MakeVectors(player.pev.v_angle);
                Vector vecForward = g_Engine.v_forward;
                Vector vecStart = player.pev.origin + player.pev.view_ofs;
                Vector vecEnd = vecStart + (vecForward * m_flHoldDistance);

                TraceResult tr;
                g_Utility.TraceLine(vecStart, vecEnd, ignore_monsters, player.edict(), tr);
                if (tr.flFraction < 1.0f)
                {
                    vecEnd = tr.vecEndPos - (vecForward * 16.0f);
                }

                g_EntityFuncs.SetOrigin(self, vecEnd);
                self.pev.velocity = g_vecZero;

                if (m_bSyncAngles)
                {
                    self.pev.angles.y = player.pev.v_angle.y;
                }
            }

            self.pev.nextthink = g_Engine.time + 0.05f;
        }

        void ModelUse(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
        {
            CBasePlayer@ player = cast<CBasePlayer@>(pActivator);
            if (!m_bCanMove || player is null) return;

            if (!m_szAllowedTarget.IsEmpty() && string(player.pev.targetname) != m_szAllowedTarget)
            {
                g_PlayerFuncs.SayText(player, "You do not have permission to move this model.\n");
                return;
            }

            if (!m_bIsHeld)
            {
                m_hHolder = EHandle(pActivator);
                m_bIsHeld = true;
                self.pev.solid = SOLID_NOT;
                self.pev.movetype = MOVETYPE_NOCLIP;

                m_flHoldDistance = (self.pev.origin - player.pev.origin).Length();
                if (m_flHoldDistance < m_flMinHoldDist) m_flHoldDistance = m_flMinHoldDist;
                if (m_flHoldDistance > m_flMaxHoldDist) m_flHoldDistance = m_flMaxHoldDist;
            }
            else
            {
                Drop();
            }
        }

        void ModelTouch(CBaseEntity@ pOther)
        {
            if (m_bIsHeld || !m_bCanMove || pOther is null || !pOther.IsPlayer()) return;

            CBasePlayer@ player = cast<CBasePlayer@>(pOther);
            if (player is null) return;

            if (!m_szAllowedTarget.IsEmpty() && string(player.pev.targetname) != m_szAllowedTarget)
            {
                return;
            }

            Vector force = player.pev.velocity * 1.5f;
            force.z = 0.0f;
            self.pev.velocity = self.pev.velocity + force;
        }

        void Drop()
        {
            self.pev.movetype = m_bUseBounce ? MOVETYPE_BOUNCE : MOVETYPE_TOSS;
            self.pev.solid = SOLID_BBOX;
            self.pev.velocity = Vector(0, 0, -10.0f);
            m_bIsHeld = false;
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity("MoveableModel::CMoveableModel", "moveable_model");
    }
}
