%	Example 1.3-1 Paper Airplane Flight Path
%	Copyright 2005 by Robert Stengel
%	August 23, 2005

	global CL CD S m g rho	
	S		=	0.017;			% Reference Area, m^2
	AR		=	0.86;			% Wing Aspect Ratio
	e		=	0.9;			% Oswald Efficiency Factor;
	m		=	0.003;			% Mass, kg
	g		=	9.8;			% Gravitational acceleration, m/s^2
	rho		=	1.225;			% Air density at Sea Level, kg/m^3	
	CLa		=	3.141592 * AR/(1 + sqrt(1 + (AR / 2)^2));
							% Lift-Coefficient Slope, per rad
	CDo		=	0.02;			% Zero-Lift Drag Coefficient
	epsilon	=	1 / (3.141592 * e * AR);% Induced Drag Factor	
	CL		=	sqrt(CDo / epsilon);	% CL for Maximum Lift/Drag Ratio
	CD		=	CDo + epsilon * CL^2;	% Corresponding CD
	LDmax	=	CL / CD;			% Maximum Lift/Drag Ratio
	Gam		=	-atan(1 / LDmax);	% Corresponding Flight Path Angle, rad
	V		=	sqrt(2 * m * g /(rho * S * (CL * cos(Gam) - CD * sin(Gam))));
							% Corresponding Velocity, m/s
	Alpha	=	CL / CLa;			% Corresponding Angle of Attack, rad
	
%	a) Equilibrium Glide at Maximum Lift/Drag Ratio
	H		=	2;			% Initial Height, m
	R		=	0;			% Initial Range, m
	to		=	0;			% Initial Time, sec
	tf		=	6;			% Final Time, sec
	tspan	=	[to tf];
	xo		=	[V;Gam;H;R];
	[ta,xa]	=	ode23('EqMotion',tspan,xo);

    x3 = [V; 2.78*Gam; H; R];
    [tg,xg] = ode23('EqMotion', tspan, x3);
	x4 = [V; -2.78*Gam; H; R];
    [th,xh] = ode23('EqMotion', tspan, x4);

%	b) Oscillating Glide due to Zero Initial Flight Path Angle
	xo		=	[V;0;H;R];
	[tb,xb]	=	ode23('EqMotion',tspan,xo);

%	c) Effect of Increased Initial Velocity
	xo		=	[1.5*V;0;H;R];
	[tc,xc]	=	ode23('EqMotion',tspan,xo);
    x1 = [0.563*V;0;H;R];
    [te,xe] = ode23('EqMotion',tspan,x1);
    x2 = [2.11*V;0;H;R];
    [tf,xf] = ode23('EqMotion',tspan,x2);

%	d) Effect of Further Increase in Initial Velocity
	xo		=	[3*V;0;H;R];
	[td,xd]	=	ode23('EqMotion',tspan,xo);
	
	%figure
	%plot(xa(:,4),xa(:,3),xb(:,4),xb(:,3),xc(:,4),xc(:,3),xd(:,4),xd(:,3))
	%xlabel('Range, m'), ylabel('Height, m'), grid

    figure
    subplot(2,2,1)
    plot(xa(:,4),xa(:,3), 'k', xe(:,4),xe(:,3), 'r', xf(:,4),xf(:,3), 'g')
    xlabel('Range, m'), ylabel('Height, m'), grid
    legend('Initial V = 3.55 m/s', 'Initial V = 2 m/s', 'Initial V = 7.5 m/s');
    title('Varying Initial Velocity');

    subplot(2,2,3)
    plot(xa(:,4),xa(:,3),'k', xg(:,4), xg(:,3), 'r', xh(:,4), xh(:,3), 'g')
    xlabel('Range, m'), ylabel('Height, m'), grid
    legend('Initial Angle = -0.18 rad','Initial Angle = -0.5 rad','Initial Angle = 0.4 rad')
    title('Varying Initial Angle');
    sgtitle('Differences in Flight Path when Varying Initial Conditions')

    Vrange = [2,7.5];
    Grange = [-0.5,0.4];
    figure
    hold on
    tspan = [0:0.06:6];
    for i = 1:100
        Vrand = Vrange(1) + 5.5*rand(1);
        Grand = Grange(1) + 0.9*rand(1);
        
        xrand0 = [Vrand; Grand; H; R];
        [trand,xrand] = ode23('EqMotion', tspan, xrand0);
        plot(xrand(:,4),xrand(:,3))

        t_arr(i,:) = trand;
        R_arr(i,:) = xrand(:,4);
        H_arr(i,:) = xrand(:,3);
    end
    xlabel('Range, m'), ylabel('Height, m'), grid
    title('Flight Path Simulations Randomly Varying V, \gamma')

    p = polyfit(t_arr, R_arr, 10);
    R_fit = polyval(p, tspan);
    q = polyfit(t_arr, H_arr, 15);
    H_fit = polyval(q, tspan);

    figure
    plot(R_fit, H_fit);
    xlabel('Range (m)'); ylabel('Height (m)'), grid;
    title('Average Fligth Path of Simulation')
    
    Hdiff = diff(H_fit);
    Hdiff(101) = Hdiff(100);
    Rdiff = diff(R_fit);
    Rdiff(101) = Rdiff(100);

    figure
    subplot(2,2,1);
    plot(tspan,Hdiff);
    xlabel('Time (s)'); ylabel('Height Rate of Change (m/s)')
    title('Average Rate of Change in Height over Time');
    subplot(2,2,3);
    plot(tspan,Rdiff);
    xlabel('Time (s)'); ylabel('Range Rate of Change (m/s)')
    title('Average Rate of Change in Range over Time');



	%figure
	%subplot(2,2,1)
	%plot(ta,xa(:,1),tb,xb(:,1),tc,xc(:,1),td,xd(:,1))
	%xlabel('Time, s'), ylabel('Velocity, m/s'), grid
	%subplot(2,2,2)
	%plot(ta,xa(:,2),tb,xb(:,2),tc,xc(:,2),td,xd(:,2))
	%xlabel('Time, s'), ylabel('Flight Path Angle, rad'), grid
	%subplot(2,2,3)
	%plot(ta,xa(:,3),tb,xb(:,3),tc,xc(:,3),td,xd(:,3))
	%xlabel('Time, s'), ylabel('Altitude, m'), grid
	%subplot(2,2,4)
	%plot(ta,xa(:,4),tb,xb(:,4),tc,xc(:,4),td,xd(:,4))
	%xlabel('Time, s'), ylabel('Range, m'), grid