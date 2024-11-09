namespace MoveableModel
{
    class CMoveableModel : ScriptBaseAnimating
    {
        private CBaseEntity@ holder = null;
        private bool m_bCanMove;
        private bool m_bUseBounce = false; // Use bounce if true, otherwise use toss
        private bool m_bAllowAttackPull = true; // Allow Pull
        private bool m_bAllowAttackPush = true; // Allow Push
        private bool m_bSyncAngles = false; // Synchronize model's angles with player's angles
        private int m_iAnimSequence = 0;
        private string m_szAllowedTarget;
        private string m_szMins;
        private string m_szMaxs;
        private float m_flEffectFriction = 100.0;
        private Vector forwardOffset = Vector(64, 64, -192);
        private Vector currentOffset = Vector(0, 0, 0);  // Track the current offset
        private float verticalSpeed = 128.0;  // Z-axis speed

        int ObjectCaps()
        {
            return FCAP_IMPULSE_USE;
        }

        void Spawn()
        {
            self.pev.solid = SOLID_BBOX;
            self.pev.movetype = m_bUseBounce ? MOVETYPE_BOUNCE : MOVETYPE_TOSS;
            self.pev.friction = m_flEffectFriction / 100.0;
            self.pev.gravity = 1.0;

            Precache();
            g_EntityFuncs.SetModel(self, self.pev.model);

            Vector vecMins, vecMaxs;
            g_Utility.StringToVector(vecMins, m_szMins);
            g_Utility.StringToVector(vecMaxs, m_szMaxs);

            vecMins = vecMins * self.pev.scale;
            vecMaxs = vecMaxs * self.pev.scale;

            g_EntityFuncs.SetSize(self.pev, vecMins, vecMaxs);
            g_EntityFuncs.SetOrigin(self, self.pev.origin);

            self.pev.nextthink = g_Engine.time + 0.1;

            SetThink(ThinkFunction(this.Think));
            SetTouch(TouchFunction(this.ModelTouch));
            SetUse(UseFunction(this.ModelUse));

            PlayAnimation();
        }

        void Precache()
        {
            string modelPath = self.pev.model;
            if (!modelPath.IsEmpty())
            {
                g_Game.PrecacheModel(modelPath);
            }
            else
            {
                g_Game.AlertMessage(at_console, "Error: No model specified for moveable_model entity.\n");
                g_EntityFuncs.Remove(self);
            }
            BaseClass.Precache();
        }

        bool KeyValue(const string& in szKey, const string& in szValue)
        {
            if (szKey == "canmove")
                m_bCanMove = atoi(szValue) != 0;
            else if (szKey == "anim")
                m_iAnimSequence = atoi(szValue);
            else if (szKey == "min_size")
                m_szMins = szValue;
            else if (szKey == "max_size")
                m_szMaxs = szValue;
            else if (szKey == "allowedtarget")
                m_szAllowedTarget = szValue;
            else if (szKey == "effect_friction")
                m_flEffectFriction = atof(szValue);
            else if (szKey == "usebounce")
                m_bUseBounce = atoi(szValue) != 0;
            else if (szKey == "scale")
                self.pev.scale = atof(szValue);
            else if (szKey == "attack_pull")
                m_bAllowAttackPull = atoi(szValue) != 0;
            else if (szKey == "attack_push")
                m_bAllowAttackPush = atoi(szValue) != 0;
            else if (szKey == "sync_angles")
                m_bSyncAngles = atoi(szValue) != 0;
            else
                return BaseClass.KeyValue(szKey, szValue);

            return true;
        }

        void Think()
        {
            if (holder !is null)
            {
                // Use angles without Z-axis
                Vector viewAngles = Vector(holder.pev.angles.x, holder.pev.angles.y, 0);
                g_EngineFuncs.MakeVectors(viewAngles);
                Vector vecNewOrigin = holder.pev.origin + g_Engine.v_forward * (forwardOffset + currentOffset) + Vector(0, 0, 16);
                if (vecNewOrigin.z < 0)
                    vecNewOrigin.z = 0;

                self.pev.origin = vecNewOrigin;
                self.pev.velocity = Vector(0, 0, 0);

                if (m_bSyncAngles)
                {
                    // Synchronize the model's angles with the player's angles
                    self.pev.angles = Vector(0, holder.pev.angles.y, 0);
                }

                CBasePlayer@ player = cast<CBasePlayer@>(holder);
                if (player !is null)
                {
                    int buttons = player.pev.button;
                    if ((buttons & IN_USE) == 0)
                    {
                        Drop();
                    }

                    // Handle left click (push) and right click (pull) continuously
                    if (m_bAllowAttackPush && (buttons & IN_ATTACK) != 0)
                    {
                        Push();
                    }
                    if (m_bAllowAttackPull && (buttons & IN_ATTACK2) != 0)
                    {
                        Pull();
                    }
                }
            }
            else if (m_bCanMove)
            {
                HandleMovement();
            }

            self.pev.nextthink = g_Engine.time + 0.1;
            PlayAnimation();
        }

        void HandleMovement()
        {
            TraceResult tr;
            g_Utility.TraceLine(self.pev.origin, self.pev.origin + Vector(0, 0, -2), ignore_monsters, self.edict(), tr);

            if (tr.flFraction < 1.0)
            {
                self.pev.velocity = Vector(0, 0, 0);
            }
            else
            {
                self.pev.velocity = self.pev.velocity + Vector(0, 0, -self.pev.gravity);
            }
        }

        void ModelUse(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
        {
            CBasePlayer@ player = cast<CBasePlayer@>(pActivator);

            if (!m_bCanMove)
            {
                return;
            }

            if (!m_szAllowedTarget.IsEmpty())
            {
                if (player !is null && string(player.pev.targetname) != m_szAllowedTarget)
                {
                    g_PlayerFuncs.SayText(player, "You do not have permission to move this model.\n");
                    return;
                }
            }

            if (holder is null)
            {
                @holder = pActivator;
                self.pev.solid = SOLID_BBOX;
                self.pev.movetype = MOVETYPE_NOCLIP;
                currentOffset = Vector(0, 0, 0);  // Reset currentOffset when picked up
                PlayAnimation();
            }
            else
            {
                Drop();
            }
        }

        void ModelTouch(CBaseEntity@ pOther)
        {
            if (m_bCanMove && pOther.IsPlayer())
            {
                CBasePlayer@ player = cast<CBasePlayer@>(pOther);
                if (!m_szAllowedTarget.IsEmpty() && string(player.pev.targetname) != m_szAllowedTarget)
                {
                    return; // Exit if player is not allowed to push the model
                }
                Vector force = pOther.pev.velocity * 1.5;
                force.z = 0; // Remove Z-axis component to prevent bouncing vertically
                self.pev.velocity = self.pev.velocity + force;
            }
        }

        void Drop()
        {
            self.pev.movetype = m_bUseBounce ? MOVETYPE_BOUNCE : MOVETYPE_TOSS;
            self.pev.solid = SOLID_BBOX;
            @holder = null;
        }

        void PlayAnimation()
        {
            self.pev.sequence = m_iAnimSequence;
            self.pev.framerate = 1.0;
        }

        void Pull()
        {
            // Use angles without Z-axis
            Vector viewAngles = Vector(holder.pev.angles.x, holder.pev.angles.y, 0);
            g_EngineFuncs.MakeVectors(viewAngles);
            Vector adjustedForward = g_Engine.v_forward;
            adjustedForward.z = 0; // Ignore Z-axis
            adjustedForward = adjustedForward.Normalize();
            currentOffset = currentOffset - adjustedForward * 16 + Vector(0, 0, verticalSpeed);  // Adjust value for pull speed and add z velocity
        }

        void Push()
        {
            // Use angles without Z-axis
            Vector viewAngles = Vector(holder.pev.angles.x, holder.pev.angles.y, 0);
            g_EngineFuncs.MakeVectors(viewAngles);
            Vector adjustedForward = g_Engine.v_forward;
            adjustedForward.z = 0; // Ignore Z-axis
            adjustedForward = adjustedForward.Normalize();
            currentOffset = currentOffset + adjustedForward * 16 + Vector(0, 0, -verticalSpeed);  // Adjust value for push speed and add z velocity
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity("MoveableModel::CMoveableModel", "moveable_model");
    }
}
